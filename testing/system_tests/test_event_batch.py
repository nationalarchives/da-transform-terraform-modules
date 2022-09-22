#!/usr/bin/env python3
"""
Test if can cause event batch size related error.
"""
import logging
import argparse
import json
from datetime import datetime, timezone
from aws_test_lib.aws_tester import AWSTester
from tre_event_lib import tre_event_api
import concurrent.futures
import time

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Instantiate logger
logger = logging.getLogger(__name__)

SOURCE_PRODUCER = 'test-producer'
SOURCE_PROCESS = 'test-process'

VB_STEP_NAME_BAGIT = 'BagIt Checksum Validation'
VB_STEP_NAME_FILES = 'Files Checksum Validation'
VB_STEP_NAME_END_OK = 'bagit-validated -> Slack'

DPSG_STEP_NAME_START = 'BagIt To DRI SIP'

SEPARATOR = '#' * 80


def get_bagit_available_event_json(
        at_management: AWSTester,
        environment_name: str,
        test_consignment_ref: str,
        test_consignment_type: str,
        test_consignment_s3_bucket: str,
        test_consignment_archive_s3_path: str,
        test_consignment_checksum_s3_path: str
):
    """
    Generate a `bagit-available` event and submit it to `sns_topic_name` using
    `at_deployment`.
    """
    EVENT_BAGIT_AVAILABLE = 'bagit-available'

    # Create pre-signed URLs for BagIt tar.gz and tar.gz.sha256
    source_tar_gz_url = at_management.get_presigned_url(
        bucket=test_consignment_s3_bucket,
        key=test_consignment_archive_s3_path
    )

    source_checksum_url = at_management.get_presigned_url(
        bucket=test_consignment_s3_bucket,
        key=test_consignment_checksum_s3_path
    )

    # Create event's parameters block
    parameters_block = {
        EVENT_BAGIT_AVAILABLE: {
            'resource': {
                'resource-type': 'Object',
                'access-type': 'url',
                'value': source_tar_gz_url
            },
            'resource-validation': {
                'resource-type': 'Object',
                'access-type': 'url',
                'value': source_checksum_url,
                'validation-method': 'sha256'
            },
            'reference': test_consignment_ref
        }
    }

    # Create the event and convert this to JSON
    bagit_available_event = tre_event_api.create_event(
        consignment_type=test_consignment_type,
        environment=environment_name,
        producer=SOURCE_PRODUCER,
        process=SOURCE_PROCESS,
        event_name=EVENT_BAGIT_AVAILABLE,
        prior_event=None,
        parameters=parameters_block)


    logger.info('bagit_available_event: %s', bagit_available_event)
    bagit_available_event_json = json.dumps(bagit_available_event)
    logger.info('bagit_available_event_json: %s', bagit_available_event_json)
    return bagit_available_event_json


def sns_publish(
    at_deployment: AWSTester,
    topic_name: str,
    message: str
):
    ns = time.time_ns()
    logger.info('submit_sns nS: %s', ns)
    return at_deployment.sns_publish(
        topic_name=topic_name,
        message=message)


def main(
        aws_profile_management: str,
        aws_profile_deployment: str,
        environment_name: str,
        test_consignment_ref: str,
        test_consignment_type: str,
        test_consignment_s3_bucket: str,
        test_consignment_archive_s3_path: str,
        test_consignment_checksum_s3_path: str,
        message_count: int
):
    """
    Run the end-to-end test.
    """
    logger.info('main: aws_profile_management=%s aws_profile_deployment=%s '
        'environment_name=%s test_consignment_s3_bucket=%s '
        'test_consignment_archive_s3_path=%s '
        'test_consignment_checksum_s3_path=%s test_consignment_ref=%s',
        aws_profile_management, aws_profile_deployment, environment_name,
        test_consignment_s3_bucket, test_consignment_archive_s3_path,
        test_consignment_checksum_s3_path, test_consignment_ref)

    at_management = AWSTester(aws_profile=aws_profile_management)
    at_deployment = AWSTester(aws_profile=aws_profile_deployment)
    tre_in_topic = f'{environment_name}-tre-in'  # deployment account

    # Send bagit-available to tre-in
    logger.info(SEPARATOR)
    message_list = []
    for _ in range(message_count):
        message_list.append(
            get_bagit_available_event_json(
                at_management=at_management,
                environment_name=environment_name,
                test_consignment_ref=test_consignment_ref,
                test_consignment_type=test_consignment_type,
                test_consignment_s3_bucket=test_consignment_s3_bucket,
                test_consignment_archive_s3_path=test_consignment_archive_s3_path,
                test_consignment_checksum_s3_path=test_consignment_checksum_s3_path
            )
        )
    
    logger.info('len(message_list)=%s', len(message_list))

    # with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
    with concurrent.futures.ThreadPoolExecutor() as executor:
        logger.info('executor max_workers: %s', executor._max_workers)
        futures_dict = {
            executor.submit(sns_publish, at_deployment, tre_in_topic, message): message for message in message_list
        }

        logger.info('futures_dict: %s', futures_dict)

        for future in concurrent.futures.as_completed(futures_dict):
            logger.info('future.result(): %s', future.result())


if __name__ == "__main__":
    """
    Process CLI arguments and invoke main method.
    """
    parser = argparse.ArgumentParser(
        description=(
            'Runs an end-to-end test from a bagit-available event on tre-in to'
            'a dri-preingest-sip-available event on tre-out.'))

    parser.add_argument('--aws_profile_management', type=str, required=True,
        help='AWS_PROFILE name for management account (test data source)')
    parser.add_argument('--aws_profile_deployment', type=str, required=True,
        help='AWS_PROFILE name for deployment account (where test runs)')
    parser.add_argument('--environment_name', type=str, required=True,
        help='Name of environment being tested; e.g. dev, test, int, ...')
    parser.add_argument('--test_consignment_s3_bucket', type=str, required=True,
        help='The s3 bucket holding the test consignment to use for the test')
    parser.add_argument('--test_consignment_archive_s3_path', type=str,
        required=True, help='S3 path of the test consignment archive (tar.gz)')
    parser.add_argument('--test_consignment_checksum_s3_path', type=str,
        required=True,
        help='S3 path of the test consignment checksum (tar.gz.sha256)')
    parser.add_argument('--test_consignment_ref', type=str, required=True,
        help='The consignment reference to use for the tests')
    parser.add_argument('--test_consignment_type', type=str, default='judgment',
        help='The consignment reference type for the event')
    parser.add_argument('--message_count', type=int, required=True,
        help='Number of messages to attempt to send simultaneously')

    args = parser.parse_args()

    main(
        aws_profile_management=args.aws_profile_management,
        aws_profile_deployment=args.aws_profile_deployment,
        environment_name=args.environment_name,
        test_consignment_ref=args.test_consignment_ref,
        test_consignment_type=args.test_consignment_type,
        test_consignment_s3_bucket=args.test_consignment_s3_bucket,
        test_consignment_archive_s3_path=args.test_consignment_archive_s3_path,
        test_consignment_checksum_s3_path=args.test_consignment_checksum_s3_path,
        message_count=args.message_count
    )
    
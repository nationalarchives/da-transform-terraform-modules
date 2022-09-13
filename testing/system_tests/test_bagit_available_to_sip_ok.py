#!/usr/bin/env python3
# Run the following test steps:
# 1. Send a bagit-available event for a standard consignment to ${env}-tre-in
# 2. Confirm Step Function ${env}-tre-validate-bagit runs OK 
# 3. Confirm Step Function ${env}-dri-preingest-sip-generation runs OK
import logging
import argparse
import json
from datetime import datetime, timezone
from aws_test_lib.aws_tester import AWSTester
from tre_event_lib import tre_event_api

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Instantiate logger
logger = logging.getLogger(__name__)

SOURCE_PRODUCER = 'test-producer'
SOURCE_PROCESS = 'test-process'
SOURCE_CONSIGNMENT_TYPE = 'standard'


def publish_bagit_available_event(
        at_management: AWSTester,
        at_deployment: AWSTester,
        start_dtm: datetime,
        sns_topic_name: str,
        environment_name: str,
        test_consignment_ref: str,
        test_consignment_type: str,
        test_consignment_s3_bucket: str,
        test_consignment_archive_s3_path: str,
        test_consignment_checksum_s3_path: str
):
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
    
    at_deployment.sns_publish(
        topic_name=sns_topic_name,
        message=bagit_available_event_json)

    step_function_name = f'{environment_name}-tre-validate-bagit'
    execution_detail_key_path='input.parameters.bagit-available.reference'
    step_function_executions = at_deployment.get_step_function_executions(
        step_function_name=step_function_name,
        from_date=start_dtm,
        execution_detail_key_path=execution_detail_key_path,
        execution_detail_key_value=test_consignment_ref
    )

    if len(step_function_executions) == 0:
        raise ValueError(f'Failed to find step function execution for '
                f'{step_function_name} with execution value '
                f'"{test_consignment_ref}" at key {execution_detail_key_path}')

    if step_function_executions[0]['status'] != 'SUCCEEDED':
        raise ValueError(f'Unexpected status "{step_function_executions[0]["status"]}"')


def await_dri_preingest_sip_generation(
        at_deployment: AWSTester,
        start_dtm: datetime,
        environment_name: str,
        test_consignment_ref: str
):
    logger.info(f'await_dri_preingest_sip_generation: %s %s %s',
        start_dtm, environment_name, test_consignment_ref)

    step_function_name = f'{environment_name}-tre-dri-preingest-sip-generation'
    execution_detail_key_path='input.parameters.bagit-validated.reference'
    step_function_executions = at_deployment.get_step_function_executions(
        step_function_name=step_function_name,
        from_date=start_dtm,
        execution_detail_key_path=execution_detail_key_path,
        execution_detail_key_value=test_consignment_ref
    )    

    if len(step_function_executions) == 0:
        raise ValueError(f'Failed to find step function execution for '
                f'{step_function_name} with execution value '
                f'"{test_consignment_ref}" at key {execution_detail_key_path}')

    if step_function_executions[0]['status'] != 'SUCCEEDED':
        raise ValueError(f'Unexpected status "{step_function_executions[0]["status"]}"')


def main(
        aws_profile_management: str,
        aws_profile_deployment: str,
        environment_name: str,
        test_consignment_ref: str,
        test_consignment_s3_bucket: str,
        test_consignment_archive_s3_path: str,
        test_consignment_checksum_s3_path: str
):
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
    s3_output_bucket=f'{environment_name}-tre-common-data'  # deployment account
    start_dtm = datetime.now(tz=timezone.utc)

    # Send bagit-available to tre-in
    logger.info('#' * 60)
    publish_bagit_available_event(
        at_management=at_management,
        at_deployment=at_deployment,
        start_dtm=start_dtm,
        sns_topic_name=tre_in_topic,
        environment_name=environment_name,
        test_consignment_ref=test_consignment_ref,
        test_consignment_type=SOURCE_CONSIGNMENT_TYPE,
        test_consignment_s3_bucket=test_consignment_s3_bucket,
        test_consignment_archive_s3_path=test_consignment_archive_s3_path,
        test_consignment_checksum_s3_path=test_consignment_checksum_s3_path)

    # Wait for dri-preingest-sip-generation
    logger.info('#' * 60)
    await_dri_preingest_sip_generation(
        at_deployment=at_deployment,
        start_dtm=start_dtm,
        environment_name=environment_name,
        test_consignment_ref=test_consignment_ref)

    logger.info('To see output, run: aws --profile %s s3 ls %s',
        aws_profile_deployment, s3_output_bucket)

    logger.info('###########################################################')
    logger.info('#                 All tests completed OK                  #')
    logger.info('###########################################################')


if __name__ == "__main__":
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

    args = parser.parse_args()

    main(
        aws_profile_management=args.aws_profile_management,
        aws_profile_deployment=args.aws_profile_deployment,
        environment_name=args.environment_name,
        test_consignment_ref=args.test_consignment_ref,
        test_consignment_s3_bucket=args.test_consignment_s3_bucket,
        test_consignment_archive_s3_path=args.test_consignment_archive_s3_path,
        test_consignment_checksum_s3_path=args.test_consignment_checksum_s3_path
    )

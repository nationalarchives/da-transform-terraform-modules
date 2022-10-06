#!/usr/bin/env python3
"""
Run the following test steps:
1. Send a bagit-available event for a standard consignment to ${env}-tre-in
2. Confirm Step Function ${env}-tre-validate-bagit runs OK 
3. Confirm Step Function ${env}-dri-preingest-sip-generation runs OK
"""
import logging
import argparse
import json
import os
import hashlib
import requests
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

VB_STEP_NAME_BAGIT = 'BagIt Checksum Validation'
VB_STEP_NAME_FILES = 'Files Checksum Validation'
VB_STEP_NAME_END_OK = 'bagit-validated'

DPSG_STEP_NAME_START = 'BagIt To DRI SIP'
DPSG_STEP_NAME_END_OK = 'dri-preingest-sip-available -> Slack'

SEPARATOR = '#' * 80


def publish_bagit_available_event(
        at_management: AWSTester,
        at_deployment: AWSTester,
        sns_topic_name: str,
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
    
    at_deployment.sns_publish(
        topic_name=sns_topic_name,
        message=bagit_available_event_json)


def get_step_results(
        at_deployment: AWSTester,
        step_function_execution_arn: str,
        return_step_result_for: list
):
    """
    Get the input and output result block for the requested steps of the
    step function execution.
    """
    step_results = {}
    for step_name in return_step_result_for:
        step_results[step_name] = at_deployment.get_step_function_step_result(
            arn=step_function_execution_arn,
            step_name=step_name)
    
    return step_results


def await_validate_bagit(
        at_deployment: AWSTester,
        start_dtm: datetime,
        environment_name: str,
        test_consignment_ref: str,
        return_step_result_for: list
):
    """
    Wait for a `validate-bagit` step function execution to complete that is for
    `test_consignment_ref` after `start_dtm` and return the results (the input
    and output JSON) for the steps listed in `return_step_result_for`.
    """
    logger.info(f'await_validate_bagit: %s %s %s',
        start_dtm, environment_name, test_consignment_ref)

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

    return get_step_results(
        at_deployment=at_deployment,
        step_function_execution_arn=step_function_executions[0]['executionArn'],
        return_step_result_for=return_step_result_for
    )

def await_dri_preingest_sip_generation(
        at_deployment: AWSTester,
        start_dtm: datetime,
        environment_name: str,
        test_consignment_ref: str,
        return_step_result_for: list
):
    """
    Wait for a `dri-preingest-sip-generation` step function execution to
    complete that is for `test_consignment_ref` after `start_dtm` and return
    the results (the input and output JSON) for the steps listed in
    `return_step_result_for`.
    """
    logger.info(f'await_dri_preingest_sip_generation: %s %s %s %s',
        start_dtm, environment_name, test_consignment_ref,
        return_step_result_for)

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

    return get_step_results(
        at_deployment=at_deployment,
        step_function_execution_arn=step_function_executions[0]['executionArn'],
        return_step_result_for=return_step_result_for
    )


def validate_vb(
    step_results: str,
    expected_s3_bucket: str
):
    """
    Check the results from a `validate-bagit` flow are valid.
    """
    step_end_input = step_results[VB_STEP_NAME_END_OK]['input']
    assert 'version' in step_end_input, 'Missing version'
    assert 'timestamp' in step_end_input, 'Missing timestamp'
    assert 'UUIDs' in step_end_input, 'Missing UUIDs'
    assert 'parameters' in step_end_input, 'Missing parameters'
    parameters = step_end_input['parameters']['bagit-validated']
    assert parameters['s3-bucket'] == expected_s3_bucket, 'Invalid s3-bucket value'
    assert 'reference' in parameters, 'reference key is missing'
    assert 's3-bucket' in parameters, 's3-bucket key is missing'
    assert 's3-bagit-name' in parameters, 's3-bagit-name key is missing'
    assert 's3-object-root' in parameters, 's3-object-root key is missing'
    assert 'validated-files' in parameters, 'validated-files key is missing'
    parameters_vf = parameters['validated-files']
    assert 'path' in parameters_vf, 'path key is missing'
    assert 'root' in parameters_vf, 'root key is missing'
    assert 'data' in parameters_vf, 'data key is missing'


def save_url_to_file(url: str, output_file: str):
    logger.info(f'save_url_to_file: url={url} output_file={output_file}')
    with requests.get(url=url, stream=True) as r:
        r.raise_for_status()
        with open(output_file, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)


def get_sha256(filename: str) -> str:
    sha256 = hashlib.sha256()
    with open(filename, 'rb') as fp:
        while True:
            block = fp.read(sha256.block_size)
            if not block:
                break
            sha256.update(block)

    return sha256.hexdigest()


def validate_dpsg(
    step_results: str
):
    """
    Check the results from a `dri-preingest-sip-generation` flow are valid.
    """
    KEY_URL_ARCHIVE = 's3-folder-url'
    KEY_URL_CHECKSUM = 's3-sha256-url'

    step_end_input = step_results[DPSG_STEP_NAME_END_OK]['input']
    assert 'version' in step_end_input, 'Missing version'
    assert 'timestamp' in step_end_input, 'Missing timestamp'
    assert 'UUIDs' in step_end_input, 'Missing UUIDs'
    assert 'parameters' in step_end_input, 'Missing parameters'

    parameters = step_end_input['parameters']['dri-preingest-sip-available']
    assert 'reference' in parameters, 'reference key is missing'
    assert KEY_URL_ARCHIVE in parameters, f'{KEY_URL_ARCHIVE} key is missing'
    assert KEY_URL_CHECKSUM in parameters, f'{KEY_URL_CHECKSUM} key is missing'
    assert 'file-type' in parameters, 'file-type key is missing'

    tmp_dir = f'.tmp-test-output-{datetime.now(tz=timezone.utc).isoformat()}'
    if os.path.exists(tmp_dir):
        raise ValueError(f'Temporary output dir "{tmp_dir}" already exists')    
    os.makedirs(tmp_dir)

    local_checksum_file = os.path.join(tmp_dir, KEY_URL_CHECKSUM)
    save_url_to_file(
        url=parameters[KEY_URL_CHECKSUM],
        output_file=local_checksum_file)

    checksum_file_content = None
    with open(local_checksum_file, 'r') as fp:
        checksum_file_content = fp.read()
    
    expected_sha256 = checksum_file_content.strip().split()[0]
    logger.info('expected_sha256=%s', expected_sha256)

    local_archive_file = os.path.join(tmp_dir, KEY_URL_ARCHIVE)
    save_url_to_file(
        url=parameters[KEY_URL_ARCHIVE],
        output_file=local_archive_file)

    calculated_sha256 = get_sha256(filename=local_archive_file)
    logger.info('calculated_sha256=%s', calculated_sha256)

    assert expected_sha256 == calculated_sha256, 'Calculated sha256 did not match source sha256'


def main(
        aws_profile_management: str,
        aws_profile_deployment: str,
        environment_name: str,
        test_consignment_ref: str,
        test_consignment_type: str,
        test_consignment_s3_bucket: str,
        test_consignment_archive_s3_path: str,
        test_consignment_checksum_s3_path: str
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
    s3_output_bucket=f'{environment_name}-tre-common-data'  # deployment account
    start_dtm = datetime.now(tz=timezone.utc)

    # Send bagit-available to tre-in
    logger.info(SEPARATOR)
    publish_bagit_available_event(
        at_management=at_management,
        at_deployment=at_deployment,
        sns_topic_name=tre_in_topic,
        environment_name=environment_name,
        test_consignment_ref=test_consignment_ref,
        test_consignment_type=test_consignment_type,
        test_consignment_s3_bucket=test_consignment_s3_bucket,
        test_consignment_archive_s3_path=test_consignment_archive_s3_path,
        test_consignment_checksum_s3_path=test_consignment_checksum_s3_path)

    # Wait for validate-bagit step function
    logger.info(SEPARATOR)
    vb_step_results = await_validate_bagit(
        at_deployment=at_deployment,
        start_dtm=start_dtm,
        environment_name=environment_name,
        test_consignment_ref=test_consignment_ref,
        return_step_result_for=[
            VB_STEP_NAME_BAGIT,
            VB_STEP_NAME_FILES,
            VB_STEP_NAME_END_OK
        ]
    )

    logger.info('vb_step_results=%s', json.dumps(vb_step_results, indent=2))

    # Check Validate BagIt flow step results
    validate_vb(
        step_results=vb_step_results,
        expected_s3_bucket=s3_output_bucket
    )

    # Wait for dri-preingest-sip-generation step function
    logger.info(SEPARATOR)
    dpsg_step_results = await_dri_preingest_sip_generation(
        at_deployment=at_deployment,
        start_dtm=start_dtm,
        environment_name=environment_name,
        test_consignment_ref=test_consignment_ref,
        return_step_result_for=[DPSG_STEP_NAME_START, DPSG_STEP_NAME_END_OK])

    logger.info('dpsg_step_results=%s', json.dumps(dpsg_step_results, indent=2))

    # Check dri-preingest-sip-generation flow step results
    validate_dpsg(step_results=dpsg_step_results)

    logger.info('To see output, run: aws --profile %s s3 ls %s',
        aws_profile_deployment, s3_output_bucket)

    logger.info('###########################################################')
    logger.info('#                 All tests completed OK                  #')
    logger.info('###########################################################')


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
    parser.add_argument('--test_consignment_type', type=str, default='standard',
        help='The consignment reference type for the event (standard to pass)')

    args = parser.parse_args()

    main(
        aws_profile_management=args.aws_profile_management,
        aws_profile_deployment=args.aws_profile_deployment,
        environment_name=args.environment_name,
        test_consignment_ref=args.test_consignment_ref,
        test_consignment_type=args.test_consignment_type,
        test_consignment_s3_bucket=args.test_consignment_s3_bucket,
        test_consignment_archive_s3_path=args.test_consignment_archive_s3_path,
        test_consignment_checksum_s3_path=args.test_consignment_checksum_s3_path
    )

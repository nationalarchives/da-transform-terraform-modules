#!/usr/bin/env python3
import logging
from aws_test_lib.aws_tester import AWSTester
from datetime import datetime, timezone
import json
from . import utils

MESSAGE_VERSION = '1.0.0'

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Instantiate logger
logger = logging.getLogger(__name__)


def test_ok_path(
        at_management: AWSTester,
        at_deployment: AWSTester,
        env: str,
        s3_test_data_bucket: str,
        s3_output_bucket: str,
        consignment_type: str,
        consignment_ref: str,
        sns_input_topic: str = None  # run step function directly if set to None
):
    logger.info(f'test_ok_path start: env={env} '
                f'consignment_ref={consignment_ref} '
                f'consignment_type={consignment_type}')

    # Remove any data from prior run of the consignment ref
    s3_delete_prefix = f'consignments/{consignment_type}/{consignment_ref}/'
    at_deployment.delete_from_s3(
        s3_bucket_name=s3_output_bucket,
        s3_object_prefix=s3_delete_prefix)

    s3_bagit_url = at_management.get_presigned_url(
        bucket=s3_test_data_bucket,
        key=f'consignments/{consignment_type}/{consignment_ref}.tar.gz')

    s3_sha_url = at_management.get_presigned_url(
        bucket=s3_test_data_bucket,
        key=f'consignments/{consignment_type}/{consignment_ref}.tar.gz.sha256')

    input_dict = utils.create_tdr_message(
        environment=env,
        consignment_type=consignment_type,
        consignment_ref=consignment_ref,
        s3_bagit_url=s3_bagit_url,
        s3_sha_url=s3_sha_url)

    step_function_name = f'{env}-tre-validate-bagit'
    start_dtm = datetime.now(tz=timezone.utc)

    if sns_input_topic is None:
        run_step_function_result = at_deployment.run_step_function(
            name=step_function_name,
            input=json.dumps(input_dict))

        logger.info(f'run_step_function_result={run_step_function_result}')
    else:
        sns_publish_result = at_deployment.sns_publish(
            topic_name=sns_input_topic,
            message=json.dumps(input_dict))

        logger.info(f'sns_publish_result={sns_publish_result}')

    execution_detail_key_path = 'input.parameters.bagit-available.reference'
    step_function_executions = at_deployment.get_step_function_executions(
        step_function_name=step_function_name,
        from_date=start_dtm,
        execution_detail_key_path=execution_detail_key_path,
        execution_detail_key_value=consignment_ref
    )

    if len(step_function_executions) == 0:
        raise ValueError(f'Failed to find step function execution for '
                         f'{step_function_name} with execution value '
                         f'"{consignment_ref}" at key {execution_detail_key_path}')

    if step_function_executions[0]['status'] != 'SUCCEEDED':
        raise ValueError(f'Unexpected status "{step_function_executions[0]["status"]}"')

    step_result = at_deployment.get_step_function_step_result(
        arn=step_function_executions[0]['executionArn'],
        step_name='Files Checksum Validation')

    logger.info(f'type(step_result)={type(step_result)}')
    logger.info(f'step_result={step_result}')

    output = step_result['output']
    assert 'version' in output, 'Missing version'
    assert 'timestamp' in output, 'Missing timestamp'
    assert 'UUIDs' in output, 'Missing UUIDs'
    assert 'parameters' in output, 'Missing parameters'

    parameters_tre = output['parameters']['bagit-validated']
    assert parameters_tre.get("errors") is None, 'Error count > 0'
    assert parameters_tre['s3-bucket'] == s3_output_bucket, 'Invalid s3-bucket value'
    assert 's3-object-root' in parameters_tre, 's3-object-root key is missing'
    assert 's3-bagit-name' in parameters_tre, 's3-bagit-name key is missing'

    sns_step_result = at_deployment.get_step_function_step_result(
        arn=step_function_executions[0]['executionArn'],
        step_name='SNS tre-internal')

    logger.info(f'sns_step_result={sns_step_result}')

    step_function_response = step_function_executions[0]['status']

    logger.info(f'end_step_result status code={step_function_response}')
    assert step_function_response == "SUCCEEDED", f'Expected SUCCEEDED "{step_function_response}"'
    logger.info('')

    logger.info('=' * 150)
    logger.info(('=' * 48) + f" test path completed OK for {consignment_type} consignment type " + ('=' * 48))
    logger.info('=' * 150)

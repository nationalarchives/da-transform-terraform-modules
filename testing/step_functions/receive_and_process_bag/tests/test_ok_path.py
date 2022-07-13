import logging
from aws_test_lib.aws_tester import AWSTester
from datetime import datetime, timezone
import json

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
        consignment_type: str,
        consignment_ref: str
):
    logger.info(f'test_ok_path start: env={env} '
        f'consignment_ref={consignment_ref} '
        f'consignment_type={consignment_type}')

    s3_test_data_bucket = 'dev-te-testdata'  # management account
    s3_output_bucket = f'{env}-tre-temp'  # deployment account

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

    input_dict = {
        'consignment-reference': consignment_ref,
        'consignment-type': consignment_type,
        's3-bagit-url': s3_bagit_url,
        's3-sha-url': s3_sha_url,
        'number-of-retries': 0
    }

    step_function_name = f'{env}-tre-receive-and-process-bag'
    start_dtm = datetime.now(tz=timezone.utc)

    # Use detail field to simplify possible future adoption of Event Bridge message format
    sf_input = {
        'detail': input_dict
    }

    at_deployment.run_step_function(
        name=step_function_name,
        input=json.dumps(sf_input))

#     submission_result = at_deployment.put_event_bridge_event(
#             event_bus_name='',
#             detail_type='TDR Consignment',
#             source='uk.gov.nationalarchives.test',
#             payload=input_dict
#     )

#     logger.info(f'submission_result={submission_result}')

    execution_detail_key_path='input.detail.consignment-reference'
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
    assert not step_result['input']['error'], 'Expected input error to be False but it was not'
    assert not step_result['output']['error'], 'Expected output error to be False but it was not'
    
    result_value = step_result['output']['s3-bucket']
    assert result_value == s3_output_bucket, f's3-bucket is "{result_value}" not "{s3_output_bucket}"'
    
    assert 's3-object-root' in step_result['output'], f's3-object-root key is missing'
    assert 's3-bagit-name' in step_result['output'], f's3-bagit-name key is missing'

    end_step_result = at_deployment.get_step_function_step_result(
          arn=step_function_executions[0]['executionArn'],
          step_name='Slack Alert Completed Successfully')

    logger.info(f'end_step_result={end_step_result}')
    http_status_code = end_step_result['output']['SdkHttpMetadata']['HttpStatusCode']
    assert http_status_code == 200, f'Expected HTTP status code 200 but got "{http_status_code}"'
    logger.info('test_ok_path completed OK')

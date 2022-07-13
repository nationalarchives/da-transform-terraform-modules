import logging
import boto3
import os
from datetime import datetime
import time
import json
import uuid

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Instantiate logger
logger = logging.getLogger(__name__)


class AWSTester():
    ENV_AWS_PROFILE = 'AWS_PROFILE'


    def __init__(
            self,
            aws_profile=None
    ):
        logger.info(f'AWSTester __init__ : aws_profile={aws_profile}')

        # Fallback to AWS_PROFILE env var if no AWS profile(s) specified
        if (aws_profile is None) or (len(aws_profile) == 0):
            if (
              (self.ENV_AWS_PROFILE in os.environ) and 
              (len(os.environ[self.ENV_AWS_PROFILE]) > 0)
            ):
                aws_profile = os.environ[self.ENV_AWS_PROFILE]
            else:
                raise ValueError('No AWS environment specified or set in '
                    f'{self.ENV_AWS_PROFILE}')

        self.aws_session = boto3.Session(profile_name=aws_profile)                 
        self.aws_client_s3 = self.aws_session.client('s3')
        self.aws_resource_s3 = self.aws_session.resource('s3')
        self.aws_client_sqs = self.aws_session.client('sqs')
        self.aws_client_sf = self.aws_session.client('stepfunctions')
        self.aws_client_eb = self.aws_session.client('events')  # EventBridge


    def put_event_bridge_event(
            self,
            event_bus_name: str,
            source: str,
            detail_type: str,
            payload: dict
    ) -> dict:
        logger.info(f'put_event_bridge_event: event_bus_name={event_bus_name} payload={payload}')
        entries = [
            {
                'EventBusName': event_bus_name,
                'Source': source,
                'DetailType': detail_type,
                'Detail': json.dumps(payload)
            }
        ]

        result = self.aws_client_eb.put_events(Entries=entries)
        logger.info(f'result={result}')

        if int(result['FailedEntryCount']) > 0:
            raise ValueError(result)

        return result


    def send_sqs_message(
            self,
            sqs_message: str,
            sqs_url: str
    ) -> str:
        logger.info(f'send_sqs_message: sqs_url={sqs_url} sqs_message={sqs_message}')

        sqs_response = self.aws_client_sqs.send_message(
            QueueUrl=sqs_url,
            MessageBody=sqs_message
        )

        logger.info(f'sqs_response={sqs_response}')

        if sqs_response['ResponseMetadata']['HTTPStatusCode'] != 200:
            raise ValueError(f'Send to "{sqs_url}" did not return '
                f'HTTPStatusCode 200; response was: {sqs_response}')

        return sqs_response


    def get_step_function_arn(
            self,
            name: str
    ) -> str:
        logger.info(f'get_step_function_arn: name={name}')
        paginator = self.aws_client_sf.get_paginator('list_state_machines')
        for page in paginator.paginate():
            for machine in page['stateMachines']:
                if machine['name'] == name:
                    return machine['stateMachineArn']

        raise ValueError(f'ARN not found for step function mame "{name}"')
    

    def get_presigned_url(
            self,
            bucket: str,
            key: str,
            expiry_seconds: int=60
    ) -> str:
        logger.info(f'get_presigned_url: bucket={bucket} key={key} expiry_seconds={expiry_seconds}')
        presiged_url = self.aws_client_s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket, 'Key': key},
            ExpiresIn=expiry_seconds)
        logger.info(f'presiged_url={presiged_url}')
        return presiged_url


    def run_step_function(
            self,
            name: str,
            input: str,
            execution_name: str=None
    ) -> dict:
        logger.info(f'run_step_function: name={name} input={input} execution_name={execution_name}')
        arn = self.get_step_function_arn(name=name)
        logger.info(f'arn={arn}')

        if execution_name is None:
            execution_name = f'aws_tester_{uuid.uuid4().hex}_{name}'[:80]
            logger.info(f'execution_name={execution_name}')

        if len(execution_name) > 80:
            raise ValueError('Step function execution name exceeds 80 '
                    f'characters ("{"{execution_name}" }")')

        return self.aws_client_sf.start_execution(
            stateMachineArn=arn,
            name=execution_name,
            input=input
        )


    def describe_step_function_execution(
            self,
            step_function_execution_arn: str
    ) -> dict:
        logger.info(f'describe_step_function_execution start: '
                f'step_function_execution_arn={step_function_execution_arn}')

        execution = self.aws_client_sf.describe_execution(executionArn=step_function_execution_arn)
        logger.info(f'execution={execution}')
        return execution


    def get_dict_key_value(self, source: dict, key_path: list):
        logger.info(f'get_dict_key_value start: key_path={key_path}')
        current_search_key = key_path.pop()

        for source_key in source:
            if source_key == current_search_key:  # found matching current key
                if len(key_path) == 0:  # nothing else to find, return result
                    return source[source_key]
                elif type(source[source_key]) is dict:
                    return self.get_dict_key_value(
                            source=source[source_key],
                            key_path=key_path)
                elif type(source[source_key]) is str:  # check for JSON
                    try:
                        json_as_dict = json.loads(source[source_key])
                        return self.get_dict_key_value(
                                source=json_as_dict,
                                key_path=key_path)
                    except ValueError:  # not able to look further
                        return None
                else:  # still keys to find, but no records to search
                    return None

        return None


    def dict_path_contains_value(self, source: dict, key_path: str, value: str) -> bool:
        logger.info(f'dict_path_contains_value start: key_path={key_path} value={value}')
        keys = list(reversed(key_path.split('.')))
        logger.info(f'keys={keys}')
        dict_key_value = self.get_dict_key_value(source=source, key_path=keys)
        logger.info(f'dict_key_value={dict_key_value}')
        if dict_key_value is None:
            return False
        else:
            return value in dict_key_value


    def filter_by_execution_detail(
            self,
            execution_list: list,
            execution_detail_key_path: str=None,
            execution_detail_key_value: str=None,
            stop_when_find_more_than: int=0
    ) -> list:
        logger.info('filter_by_execution_detail: start: '
                f'execution_detail_key_path={execution_detail_key_path} '
                f'execution_detail_key_value={execution_detail_key_value}')
        
        if execution_detail_key_path is None:
            return execution_list
        
        result = []

        for e in execution_list:
            detail = self.describe_step_function_execution(
                    step_function_execution_arn=e['executionArn'])

            if self.dict_path_contains_value(
                    source=detail,
                    key_path=execution_detail_key_path,
                    value=execution_detail_key_value):
                result.append(e)
                if len(result) > stop_when_find_more_than:
                    break
        
        return result
    

    def get_step_function_executions(
            self,
            step_function_name: str,
            from_date: datetime,
            name_starts_with: str='',
            name_contains: str='',
            execution_detail_key_path: str=None,
            execution_detail_key_value: str=None,
            target_status: list=['SUCCEEDED', 'FAILED', 'TIMED_OUT', 'ABORTED'],
            max_reties: int=180,
            wait_secs: int=1,
            stop_poll_when_more_than: int=0
    ):
        """
        target_status: 'RUNNING'|'SUCCEEDED'|'FAILED'|'TIMED_OUT'|'ABORTED'
        """
        # Poll for the specified Step Function execution
        logger.info(f'get_step_function_executions: start: '
                f'from_date={from_date} name_starts_with={name_starts_with}'
                f'name_contains={name_contains} '
                f'execution_detail_key_path={execution_detail_key_path} '
                f'name_contains={name_contains} '
                f'execution_detail_key_value={execution_detail_key_value} '
                f'max_reties={max_reties} wait_secs={wait_secs}'
                f'stop_poll_when_more_than={stop_poll_when_more_than}')

        found = False  
        retry = 0
        filtered_result = []
        sf_arn = self.get_step_function_arn(name=step_function_name)
        logger.info(f'sf_arn={sf_arn}')

        while not found and retry < max_reties:
            retry += 1

            # Can only filter by status here; filter by prefix after call
            result = self.aws_client_sf.list_executions(
                    stateMachineArn=sf_arn)
            
            # Filter by name, time and multiple status values; boto3 API can't
            filtered_result = [
                e for e in result['executions']
                if (
                    e['name'].startswith(name_starts_with) and
                    (name_contains in e['name']) and
                    (e['startDate'] >= from_date) and
                    (e['status'] in target_status)
                )
            ]

            logger.info(f'get_step_function_executions: unfiltered '
                f'len(result["executions"])={len(result["executions"])} '
                f'len(filtered_result)={len(filtered_result)}')

            # Filter by optional execution detail path value
            if execution_detail_key_path is not None:
                filtered_result = self.filter_by_execution_detail(
                        execution_list=filtered_result,
                        execution_detail_key_path=execution_detail_key_path,
                        execution_detail_key_value=execution_detail_key_value
                )
                
            found = (len(filtered_result) > stop_poll_when_more_than)
            
            if not found and retry < max_reties:
                logger.info(f'get_step_function_executions: '
                        f'retry={retry}/{max_reties} wait_secs={wait_secs}')
                time.sleep(wait_secs)
            
            if found:
                return filtered_result

        raise ValueError('Timed out waiting for response; '
                f'from_date={from_date} '
                f'name_starts_with={name_starts_with} '
                f'name_contains={name_contains} '
                f'target_status={target_status} '
                f'max_reties={max_reties} '
                f'wait_secs={wait_secs} '
                f'stop_poll_when_more_than={stop_poll_when_more_than}')


    def get_step_function_step_result(
            self,
            arn: str,
            step_name: str
    ) -> dict:
        """
        Get the specified Step Function execution `arn` and return the input
        and output payloads for `step_name` in the form:

        {
            'input': ... ,
            'output': ...
        }
        """
        KEY_STATE_ENTERED = 'stateEnteredEventDetails'
        KEY_STATE_EXITED = 'stateExitedEventDetails'
        KEY_INPUT = 'input'
        KEY_OUTPUT = 'output'

        sf_history = self.aws_client_sf.get_execution_history(executionArn=arn)
        logger.debug(f'sf_history={sf_history}')

        step_input = [
            json.loads(e[KEY_STATE_ENTERED][KEY_INPUT])
            for e in sf_history['events']
            if (
                (KEY_STATE_ENTERED in e) and
                ('name' in e[KEY_STATE_ENTERED]) and
                (str(e[KEY_STATE_ENTERED]['name']) == step_name)
            )
        ]

        step_output = [
            json.loads(e[KEY_STATE_EXITED][KEY_OUTPUT])
            for e in sf_history['events']
            if (
                (KEY_STATE_EXITED in e) and
                ('name' in e[KEY_STATE_EXITED]) and
                (str(e[KEY_STATE_EXITED]['name']) == step_name)
            )
        ]

        if len(step_input) != 1:
            raise ValueError(f'Expected to find 1 input for step '
                    f'"{step_name}" but found {len(step_input)}')

        if len(step_output) != 1:
            raise ValueError(f'Expected to find 1 output for step '
                    f'"{step_name}" but found {len(step_output)}')

        return {
            KEY_INPUT: step_input[0],
            KEY_OUTPUT: step_output[0]
        }


    def delete_from_s3(
            self,
            s3_bucket_name: str,
            s3_object_prefix: str
    ):
        logger.info(f'delete_from_s3: s3_bucket_name={s3_bucket_name} s3_object_prefix={s3_object_prefix}')
        s3_bucket=self.aws_resource_s3.Bucket(s3_bucket_name)
        objects = s3_bucket.objects.filter(Prefix=s3_object_prefix)
        logger.info(f'delete_from_s3: s3_bucket={s3_bucket} objects={[o.key for o in objects]}')
        objects.delete()

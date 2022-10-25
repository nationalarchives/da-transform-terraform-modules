#!/usr/bin/env python3
import logging
import argparse
from aws_test_lib.aws_tester import AWSTester
from tests.test_ok_path import test_ok_path
from tests.test_bad_paths import test_bad_consignment_type, test_bad_checksum

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Instantiate logger
logger = logging.getLogger(__name__)


def main(
        aws_profile_management: str,
        aws_profile_deployment: str,
        environment_name: str,
        judgment_consignment_ref: str,
        standard_consignment_ref: str
):
    logger.info(f'main: aws_profile_management={aws_profile_management} '
                f'aws_profile_deployment={aws_profile_deployment} '
                f'environment_name={environment_name}'
                f'standard_consignment_ref={standard_consignment_ref}'
                f'judgement_consignment_ref={judgment_consignment_ref}')

    at_management = AWSTester(aws_profile=aws_profile_management)
    at_deployment = AWSTester(aws_profile=aws_profile_deployment)
    s3_test_data_bucket = 'dev-te-testdata'  # management account
    tre_in_topic = f'{environment_name}-tre-in'  # deployment account
    s3_output_bucket = f'{environment_name}-tre-common-data'  # deployment account

    logger.info('*' * 130)
    logger.info(('*' * 50) + ' testing bad checksum for file ' + ('*' * 50))
    logger.info('*' * 130)

    test_bad_checksum(
        at_management=at_management,
        at_deployment=at_deployment,
        env=environment_name,
        s3_test_data_bucket=s3_test_data_bucket,
        s3_output_bucket=s3_output_bucket,
        sns_input_topic=tre_in_topic
    )

    logger.info('*' * 130)
    logger.info(('*' * 50) + ' testing bad consignment type' + ('*' * 50))
    logger.info('*' * 130)

    test_bad_consignment_type(
        at_management=at_management,
        at_deployment=at_deployment,
        env=environment_name,
        s3_test_data_bucket=s3_test_data_bucket,
        s3_output_bucket=s3_output_bucket,
        consignment_ref=judgment_consignment_ref,
        sns_input_topic=tre_in_topic
    )


    logger.info('*' * 130)
    logger.info(('*' * 50) + ' testing judgment consignment ' + ('*' * 50))
    logger.info('*' * 130)
    consignment_type = 'judgment'

    test_ok_path(
        at_management=at_management,
        at_deployment=at_deployment,
        env=environment_name,
        s3_test_data_bucket=s3_test_data_bucket,
        s3_output_bucket=s3_output_bucket,
        consignment_type=consignment_type,
        consignment_ref=judgment_consignment_ref,
        sns_input_topic=tre_in_topic
    )

    logger.info(f'To see output, run: aws --profile {aws_profile_deployment} '
                f's3 ls {s3_output_bucket}/consignments/{consignment_type}'
                f'/{judgment_consignment_ref}/0/{judgment_consignment_ref}/')

    logger.info('*' * 130)
    logger.info(('*' * 50) + 'testing standard consignment' + ('*' * 50))
    logger.info('*' * 130)

    consignment_type = 'standard'

    test_ok_path(
        at_management=at_management,
        at_deployment=at_deployment,
        env=environment_name,
        s3_test_data_bucket=s3_test_data_bucket,
        s3_output_bucket=s3_output_bucket,
        consignment_type=consignment_type,
        consignment_ref=standard_consignment_ref,
        sns_input_topic=tre_in_topic
    )

    logger.info(f'To see output, run: aws --profile {aws_profile_deployment} '
                f's3 ls {s3_output_bucket}/consignments/{consignment_type}'
                f'/{standard_consignment_ref}/0/{standard_consignment_ref}/')

    logger.info('###########################################################')
    logger.info('#                 All tests completed OK                  #')
    logger.info('###########################################################')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            'Run validate_bagit step function tests.'
        ))

    parser.add_argument('--aws_profile_management', type=str,
                        help='AWS_PROFILE name for management account')
    parser.add_argument('--aws_profile_deployment', type=str,
                        help='AWS_PROFILE name for deployment account')
    parser.add_argument('--environment_name', type=str,
                        help='Name of environment to test; e.g. dev, test, int, ...')
    parser.add_argument('--judgment_consignment_ref', type=str,
                        help='The judgment consignment reference to use for the tests')
    parser.add_argument('--standard_consignment_ref', type=str,
                        help='The standard consignment reference to use for the tests')

    args = parser.parse_args()

    main(
        aws_profile_management=args.aws_profile_management,
        aws_profile_deployment=args.aws_profile_deployment,
        environment_name=args.environment_name,
        judgment_consignment_ref=args.judgment_consignment_ref,
        standard_consignment_ref=args.standard_consignment_ref
    )

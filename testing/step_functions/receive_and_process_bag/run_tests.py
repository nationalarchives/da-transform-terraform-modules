import logging
import argparse
from aws_test_lib.aws_tester import AWSTester
from tests.test_ok_path import test_ok_path

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
        test_consignment_ref: str
):
    logger.info(f'main: aws_profile_management={aws_profile_management} '
        f'aws_profile_deployment={aws_profile_deployment} '
        f'environment_name={environment_name}',
        f'test_consignment_ref={test_consignment_ref}')

    at_managament = AWSTester(aws_profile=aws_profile_management)
    at_deployment = AWSTester(aws_profile=aws_profile_deployment)

    logger.info('*** testing judgment *********' + ('*' * 50))
    test_ok_path(
        at_management=at_managament,
        at_deployment=at_deployment,
        env=environment_name,
        consignment_type='judgment',
        consignment_ref=test_consignment_ref
    )

    logger.info('*** testing standard *********' + ('*' * 50))
    test_ok_path(
        at_management=at_managament,
        at_deployment=at_deployment,
        env=environment_name,
        consignment_type='standard',
        consignment_ref=test_consignment_ref
    )

    logger.info('###########################################################')
    logger.info('#                 All tests completed OK                  #')
    logger.info('###########################################################')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            'Run receive_and_process_bag step function tests.'
        ))

    parser.add_argument('--aws_profile_management', type=str,
            help='AWS_PROFILE name for management account')
    parser.add_argument('--aws_profile_deployment', type=str,
            help='AWS_PROFILE name for deployment account')
    parser.add_argument('--environment_name', type=str,
            help='Name of environment to test; e.g. dev, test, int, ...')
    parser.add_argument('--test_consignment_ref', type=str,
            help='The consignment reference to use for the tests')

    args = parser.parse_args()

    main(
        aws_profile_management=args.aws_profile_management,
        aws_profile_deployment=args.aws_profile_deployment,
        environment_name=args.environment_name,
        test_consignment_ref=args.test_consignment_ref
    )

import os
import setuptools

env_aws_test_lib_version = os.environ['AWS_TEST_LIB_VERSION']

setuptools.setup(
    name='aws_test_lib',
    version=env_aws_test_lib_version,
    description='API for testing applications deployed to AWS',
    packages=setuptools.find_packages(exclude=['tests']),
    python_requires='>=3.8'
)

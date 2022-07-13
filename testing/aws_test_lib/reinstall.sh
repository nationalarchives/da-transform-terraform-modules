#!/usr/bin/env bash
set -e
pip3 --require-virtualenv uninstall --yes aws-test-lib
pip3 --require-virtualenv install dist/aws_test_lib*

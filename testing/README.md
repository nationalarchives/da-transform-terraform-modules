# Instructions

## 1. Setup Python virtual environment

If using VSCode, run this in VSCode's terminal and IDE will offer to adopt it:

```
# In project root
python3 -m venv .venv
```

```
# Activate venv (run 'deactivate' to disable):
. ./.venv/bin/activate
```

## 2. Install required libraries

```
pip3 install wheel
pip3 install boto3
```

## 2. Build and install aws_test_lib

```
cd testing/aws_test_lib
./build.sh && ./reinstall.sh
```

## 4. Run a test

For example, for validate_bagit tests, run the following in the
project's root folder:

```
# In project root
aws_profile_management='tna-acc-manag-admin'
aws_profile_deployment='tna-acc-dev-admin'
judgment_consignment_ref='[Judgment_Test_Consigment]'
standard_consignment_ref='[Standard_Test-Consignment]'

python3 testing/step_functions/validate_bagit/run_tests.py \
  "--aws_profile_management=${aws_profile_management}" \
  "--aws_profile_deployment=${aws_profile_deployment}" \
  --environment_name=dev \
  "--judgment_consignment_ref=${judgment_consignment_ref}" \
  "--standard_consignment_ref=${standard_consignment_ref}"
```

# System Tests

This section is intended for tests that perform end-to-end checks that use
one or more processes.

## Pre-requisites

To install required libraries:

```bash
# Create a new Python virtual environment
python3 -m venv .venv
. ./.venv/bin/activate

# Install library required for building Python packages 
pip3 install wheel

# Install AWS API
pip3 install boto3

# Build and install the aws_test_lib (using "()" to avoid losing current dir)
( \
    cd "../aws_test_lib" \
    && ./build.sh \
    && ./reinstall.sh \
)

# Build the tre_event_lib from git and install it
tre_event_lib_tag='0.0.3-alpha'
./install_tre_event_lib.sh "${tre_event_lib_tag}"
```

# test_bagit_available_to_sip_ok.py

This test performs the following actions:

* Submits a `bagit-available` event to `${env}-tre-in` for the given consignment
* Confirms Step Function `${env}-tre-validate-bagit` runs OK 
* Confirms Step Function `${env}-dri-preingest-sip-generation` runs OK

To run the test:

> Note: `consignment_type` must be `standard` for the end-to-end run to work

```bash
# Requires pre-requisite packages installed (see above section)
./test_bagit_available_to_sip_ok.py \
  --aws_profile_management "${aws_profile_management}" \
  --aws_profile_deployment "${aws_profile_deployment}" \
  --environment_name "${environment_name}" \
  --test_consignment_s3_bucket "${test_consignment_s3_bucket}" \
  --test_consignment_archive_s3_path "consignments/${consignment_type}/${consignment_ref}.tar.gz" \
  --test_consignment_checksum_s3_path "consignments/${consignment_type}/${consignment_ref}.tar.gz.sha256" \
  --test_consignment_ref "${consignment_ref}"
```

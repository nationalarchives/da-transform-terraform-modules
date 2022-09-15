# System Tests

This section is intended for tests that perform end-to-end checks that use
one or more processes.

## Pre-requisites

To install required dependencies:

```bash
# Create and activate a Python virtual environment
python3 -m venv .venv
. ./.venv/bin/activate

# Install dependent libraries (builds some; e.g. tre_event_lib 0.0.7-alpha)
./dependency_setup.sh 0.0.7-alpha
```

# test_bagit_available_to_sip_ok.py

This test performs the following actions:

* Submits a `bagit-available` event to `${env}-tre-in` for the given consignment
* Confirms Step Function `${env}-tre-validate-bagit` runs OK
  * Checks event keys
* Confirms Step Function `${env}-dri-preingest-sip-generation` runs OK
  * Checks event keys
  * Downloads output archive
  * Downloads output archive checksum file
  * Confirms downloaded archive's checksum matches that in checksum file

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

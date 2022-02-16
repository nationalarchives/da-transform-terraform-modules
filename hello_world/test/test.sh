#!/bin/bash

set -e
echo "Running terratest for hellow_world module"
go get "github.com/gruntwork-io/terratest/modules/terraform" \
   "github.com/stretchr/testify/assert" \
   "strings" \
   "testing" \
   "fmt" \
   "github.com/gruntwork-io/terratest/modules/random" \
   "github.com/gruntwork-io/terratest/modules/aws"

mkdir -p ../da-transform-terraform-modules/test/reports/hello_world

go test ../da-transform-terraform-modules/hello_world/test/hello_world_test.go -v | tee ../da-transform-terraform-modules/test/reports/hello_world_test_output.log

echo "Creating terratest logs"

terratest_log_parser -testlog ../da-transform-terraform-modules/test/reports/hello_world_test_output.log -outputdir ../da-transform-terraform-modules/test/reports/hello_world

cat test/reports/hello_world_test_output.log
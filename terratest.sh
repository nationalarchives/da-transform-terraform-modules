#!/bin/bash


set -e

go mod init test
go mod tidy

for dir in $(find ../da-transform-terraform-modules -maxdepth 1 -mindepth 1 -type d ); do
   if [[ -f "../da-transform-terraform-modules/${dir}/test/test.sh" ]]; then
        ../da-transform-terraform-modules/${dir}/test/test.sh
   fi
done
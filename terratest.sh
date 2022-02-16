#!/bin/bash


set -e

go mod init test
go mod tidy

for dir in $(find ./.git/da-transform-terraform-modules -maxdepth 1 -mindepth 1 -type d ); do
   if [[ -f "./.git/da-transform-terraform-modules/${dir}/test/test.sh" ]]; then
        ./.git/da-transform-terraform-modules/${dir}/test/test.sh
   fi
done
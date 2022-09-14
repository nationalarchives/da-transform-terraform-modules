#!/usr/bin/env bash
# Setup Python virtual environment with libraries required by system test. 
set -e

function build_and_install_tre_event_lib {
    if [ $# -ne 1 ]; then
        printf 'Usage: build_tag\n' 1>&2
        exit 1
    fi

    local tre_event_lib_tag="${1:?}"
    local repo_name='da-transform-schemas'
    local repo_url="https://github.com/nationalarchives/${repo_name:?}.git"

    printf 'Building tre_event_lib: repo_url=%s tre_event_lib_tag=%s\n' \
        "${repo_url}" "${tre_event_lib_tag}"

    local tre_event_lib_build_dir='.tmp_tre_event_lib_build_dir'
    printf 'tre_event_lib_build_dir=%s\n' "${tre_event_lib_build_dir}"
    printf 'Removing any existing build dir\n'
    rm -rfv "${tre_event_lib_build_dir}"
    printf 'Creating new build dir\n'
    mkdir "${tre_event_lib_build_dir}"
    
    git -c advice.detachedHead=false \
        clone \
        --depth 1 \
        --branch "${tre_event_lib_tag}" \
        "${repo_url}" \
        "${tre_event_lib_build_dir}"
    
    # Run build; use () to not lose current dir; pip3 install needed for tests
    local build_root="${tre_event_lib_build_dir}/tre_event_lib"
    ls -la "${build_root}"

    ( \
        cd "${build_root}" \
        && pip3 --require-virtualenv install --requirement requirements.txt \
        && ./build.sh \
    )

    # Install the built package whl file
    local pkg_whl_file
    pkg_whl_file="$(find "${build_root}/dist" -name "*.whl")"
    printf 'run: pip3 --require-virtualenv install "%s"' "${pkg_whl_file}"
    pip3 --require-virtualenv install "${pkg_whl_file:?}"
}

function main {
    if [ $# -ne 1 ]; then
        printf 'Usage: build_tag\n' 1>&2
        exit 1
    fi

    local tre_event_lib_tag="${1:?}"

    # Install library required for building Python packages 
    pip3 --require-virtualenv install wheel

    # Install AWS API
    pip3 --require-virtualenv install boto3

    # Build and install the aws_test_lib (using "()" to avoid losing current dir)
    ( \
        cd "../aws_test_lib" \
        && ./build.sh \
        && ./reinstall.sh \
    )

    # Build the tre_event_lib from git and install it
    build_and_install_tre_event_lib "${tre_event_lib_tag}"
    pip3 list
    printf 'Completed OK\n'
}

main "$@"

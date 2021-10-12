#!/usr/bin/env bash

set -euo pipefail

if [ \
    -z "${SCCACHE_AWS_SECRET_ACCESS_KEY+present}" -o \
    -z "${SCCACHE_AWS_ACCESS_KEY_ID+present}" -o \
    -z "${SCCACHE_BUCKET+present}" \
]
then
    # Bypass sccache if any of the above vars aren't set. This lets the user
    # still build with the Docker container even when they might have issues
    # reading/writing to S3.
    "$@"
else
    export AWS_ACCESS_KEY_ID="${SCCACHE_AWS_ACCESS_KEY_ID}"
    export AWS_SECRET_ACCESS_KEY="${SCCACHE_AWS_SECRET_ACCESS_KEY}"
    export SCCACHE_BUCKET="${SCCACHE_BUCKET}"
    export SCCACHE_REGION="${SCCACHE_REGION:-us-east-1}"
    export SCCACHE_S3_GET_AUTH=true

    sccache "$@"
fi

#!/bin/bash
# build and pack a rust lambda library
# https://aws.amazon.com/blogs/opensource/rust-runtime-for-aws-lambda/

set -eo pipefail
mkdir -p target/lambda
export CARGO_TARGET_DIR=$PWD/target/lambda
(
    if [[ $# -gt 0 ]]; then
        yum install -y "$@"
    fi
    # source cargo
    . $HOME/.cargo/env
    cargo build ${CARGO_FLAGS:-} --release
) 1>&2

function package() {
    file="$1"
    strip "$file"
    rm "$file.zip" > 2&>/dev/null || true
    # note: would use printf "@ $(basename $file)\n@=bootstrap" | zipnote -w "$file.zip"
    # if not for https://bugs.launchpad.net/ubuntu/+source/zip/+bug/519611
    if [ "$file" != ./bootstrap ] && [ "$file" != bootstrap ]; then
        mv "${file}" bootstrap
    fi
    zip "$file.zip" bootstrap
    rm bootstrap
}

cd "$CARGO_TARGET_DIR"/release
(
    . $HOME/.cargo/env
    if [ -z "$BIN" ]; then
        IFS=$'\n'
        for executable in $(cargo read-manifest | jq -r '.targets[] | select(.kind[] | contains("bin")) | .name'); do
          package "$executable"
        done
    else
        package "$BIN"
    fi

) 1>&2
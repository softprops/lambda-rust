#!/bin/bash
# build and pack a rust lambda library
# https://aws.amazon.com/blogs/opensource/rust-runtime-for-aws-lambda/

HOOKS_DIR="$PWD/.lambda-rust"
INSTALL_HOOK="install"
BUILD_HOOK="build"
PACKAGE_HOOK="package"

set -eo pipefail
mkdir -p target/lambda
export PROFILE=${PROFILE:-release}
export DEBUGINFO=${DEBUGINFO}
# cargo uses different names for target
# of its build profiles
if [[ "${PROFILE}" == "release" ]]; then
    TARGET_PROFILE="${PROFILE}"
else
    TARGET_PROFILE="debug"
fi
export CARGO_TARGET_DIR=$PWD/target/lambda
(
    if [[ $# -gt 0 ]]; then
        yum install -y "$@"
    fi

    if test -f "$HOOKS_DIR/$INSTALL_HOOK"; then
        echo "Running install hook"
        /bin/bash "$HOOKS_DIR/$INSTALL_HOOK"
        echo "Install hook ran successfully"
    fi

    # source cargo
    . $HOME/.cargo/env
    # cargo only supports --release flag for release
    # profiles. dev is implicit
    if [ "${PROFILE}" == "release" ]; then
        cargo build ${CARGO_FLAGS:-} --${PROFILE} --verbose
    else
        cargo build ${CARGO_FLAGS:-} --verbose
    fi

    if test -f "$HOOKS_DIR/$BUILD_HOOK"; then
        echo "Running build hook"
        /bin/bash "$HOOKS_DIR/$BUILD_HOOK"
        echo "Build hook ran successfully"
    fi
) 1>&2

function package() {
    file="$1"
    if [[ "${PROFILE}" == "release" ]] && [[ -z "${DEBUGINFO}" ]]; then
        objcopy --only-keep-debug "$file" "$file.debug"
        objcopy --strip-debug --strip-unneeded "$file"
        objcopy --add-gnu-debuglink="$file.debug" "$file"
    fi
    rm "$file.zip" > 2&>/dev/null || true
    # note: would use printf "@ $(basename $file)\n@=bootstrap" | zipnote -w "$file.zip"
    # if not for https://bugs.launchpad.net/ubuntu/+source/zip/+bug/519611
    if [ "$file" != ./bootstrap ] && [ "$file" != bootstrap ]; then
        mv "${file}" bootstrap
        mv "${file}.debug" bootstrap.debug > 2&>/dev/null || true
    fi
    zip "$file.zip" bootstrap
    rm bootstrap

    if test -f "$HOOKS_DIR/$PACKAGE_HOOK"; then
        echo "Running package hook"
        /bin/bash "$HOOKS_DIR/$PACKAGE_HOOK" $file
        echo "Package hook ran successfully"
    fi
}

cd "${CARGO_TARGET_DIR}/${TARGET_PROFILE}"
(
    . $HOME/.cargo/env
    if [ -z "$BIN" ]; then
        IFS=$'\n'
        for executable in $(cargo metadata --no-deps --format-version=1 | jq -r '.packages[] | .targets[] | select(.kind[] | contains("bin")) | .name'); do
          package "$executable"
        done
    else
        package "$BIN"
    fi

) 1>&2

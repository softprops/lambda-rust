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
export PACKAGE=${PACKAGE:-true}
export DEBUGINFO=${DEBUGINFO}
export CARGO_HOME="/cargo"
export RUSTUP_HOME="/rustup"

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
    . $CARGO_HOME/env

    CARGO_BIN_ARG="" && [[ -n "$BIN" ]] && CARGO_BIN_ARG="--bin ${BIN}"

    # cargo only supports --release flag for release
    # profiles. dev is implicit
    if [ "${PROFILE}" == "release" ]; then
        cargo build ${CARGO_BIN_ARG} ${CARGO_FLAGS:-} --${PROFILE}
    else
        cargo build ${CARGO_BIN_ARG} ${CARGO_FLAGS:-}
    fi

    if test -f "$HOOKS_DIR/$BUILD_HOOK"; then
        echo "Running build hook"
        /bin/bash "$HOOKS_DIR/$BUILD_HOOK"
        echo "Build hook ran successfully"
    fi
) 1>&2

function package() {
    file="$1"
    OUTPUT_FOLDER="output/${file}"
    if [[ "${PROFILE}" == "release" ]] && [[ -z "${DEBUGINFO}" ]]; then
        objcopy --only-keep-debug "$file" "$file.debug"
        objcopy --strip-debug --strip-unneeded "$file"
        objcopy --add-gnu-debuglink="$file.debug" "$file"
    fi
    rm "$file.zip" > 2&>/dev/null || true
    rm -r "${OUTPUT_FOLDER}" > 2&>/dev/null || true
    mkdir -p "${OUTPUT_FOLDER}"
    cp "${file}" "${OUTPUT_FOLDER}/bootstrap"
    cp "${file}.debug" "${OUTPUT_FOLDER}/bootstrap.debug" > 2&>/dev/null || true

    if [[ "$PACKAGE" != "false" ]]; then
        zip -j "$file.zip" "${OUTPUT_FOLDER}/bootstrap"
        if test -f "$HOOKS_DIR/$PACKAGE_HOOK"; then
            echo "Running package hook"
            /bin/bash "$HOOKS_DIR/$PACKAGE_HOOK" $file
            echo "Package hook ran successfully"
        fi
    fi
}

cd "${CARGO_TARGET_DIR}/${TARGET_PROFILE}"
(
    . $CARGO_HOME/env
    if [ -z "$BIN" ]; then
        IFS=$'\n'
        for executable in $(cargo metadata --no-deps --format-version=1 | jq -r '.packages[] | .targets[] | select(.kind[] | contains("bin")) | .name'); do
          package "$executable"
        done
    else
        package "$BIN"
    fi

) 1>&2

#!/bin/bash

# decor
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# test state
TESTS=0
FAILED=0

# Verify that a command succeeds
function assert_success() {
    MESSAGE="$1"
    shift
    COMMAND="$@"

    ((++TESTS))

    if $COMMAND
    then
        echo -e "👍  ${GREEN} $MESSAGE: success${NC}"
    else
        echo -e "👎  ${RED} ${MESSAGE}: fail${NC}"
        ((++FAILED))
    fi
}

function end_tests() {
    if ((FAILED > 0))
    then
        echo
        echo -e "💀  ${RED} Ran ${TESTS} tests, ${FAILED} failed.${NC}"
        exit $FAILED
    else
        echo
        echo -e "👌  ${GREEN} ${TESTS} tests passed.${NC}"
        exit 0
    fi
}

# Directory of the integration test
HERE=$(dirname $0)
# Root directory of the repository
DIST=$(cd $HERE/..; echo $PWD)

cd ${HERE}/test-func

# test packaing with a single binary
function package_bin() {
    rm target/lambda/release/ > /dev/null 2>&1
    docker run --rm \
    -e BIN="$1" \
    -v ${PWD}:/code \
    -v ${HOME}/.cargo/registry:/root/.cargo/registry \
    -v ${HOME}/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust && \
    ls target/lambda/release/test-func.zip > /dev/null 2>&1
}

# test packaging all binaries
function package_all() {
    rm target/lambda/release/ > /dev/null 2>&1
    docker run --rm \
    -v ${PWD}:/code \
    -v ${HOME}/.cargo/registry:/root/.cargo/registry \
    -v ${HOME}/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust && \
    ls target/lambda/release/test-func.zip > /dev/null 2>&1
}

# package tests
assert_success "it packages single bin" package_bin bootstrap

assert_success "it packages all bins" package_all

# verify packaged artifact by invoking it using the lambdaci "provided" docker image
rm test-out.log > /dev/null 2>&1
rm -rf /tmp/lambda > /dev/null 2>&1
unzip -o  \
    target/lambda/release/test-func.zip \
    -d /tmp/lambda > /dev/null 2>&1 && \
  docker run \
    -i -e DOCKER_LAMBDA_USE_STDIN=1 \
    --rm \
    -v /tmp/lambda:/var/task \
    lambci/lambda:provided < test-event.json | grep -v RequestId | grep -v '^\W*$' > test-out.log

assert_success "when invoked, it produces expected output" diff test-event.json test-out.log

end_tests
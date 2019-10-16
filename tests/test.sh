#!/usr/bin/env bash

# Directory of the integration test
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Root directory of the repository
DIST=$(cd "$HERE"/..; pwd)

source "${HERE}"/bashtest.sh

# test packaing with a single binary
package_bin() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -e BIN="$1" \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/root/.cargo/registry \
    -v "${HOME}"/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust && \
    ls target/lambda/release/bootstrap.zip > /dev/null 2>&1
}

# test packaging all binaries
package_all() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/root/.cargo/registry \
    -v "${HOME}"/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust && \
    ls target/lambda/release/bootstrap.zip > /dev/null 2>&1
}

# test packaging with PROFILE=dev
package_all_dev_profile() {
    rm -rf target/lambda/debug > /dev/null 2>&1
    docker run --rm \
    -e PROFILE=dev \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/root/.cargo/registry \
    -v "${HOME}"/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust && \
    ls target/lambda/debug/bootstrap.zip > /dev/null 2>&1
}

for project in test-func test-multi-func; do
    cd "${HERE}"/"${project}"

    # package tests
    if [[ "$project" == test-func ]]; then
        assert_success "it packages single bin" package_bin bootstrap
    else
        assert_success "it packages single bin" package_bin bootstrap
    fi

    assert_success "it packages all bins with dev profile" package_all_dev_profile

    assert_success "it packages all bins" package_all

    # verify packaged artifact by invoking it using the lambdaci "provided" docker image
    rm test-out.log > /dev/null 2>&1
    rm -rf /tmp/lambda > /dev/null 2>&1
    unzip -o  \
        target/lambda/release/bootstrap.zip \
        -d /tmp/lambda > /dev/null 2>&1 && \
    docker run \
        -i -e DOCKER_LAMBDA_USE_STDIN=1 \
        --rm \
        -v /tmp/lambda:/var/task \
        lambci/lambda:provided < test-event.json | grep -v RequestId | grep -v '^\W*$' > test-out.log

    assert_success "when invoked, it produces expected output" diff test-event.json test-out.log
done

end_tests
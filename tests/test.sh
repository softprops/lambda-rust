#!/usr/bin/env bash

# Directory of the integration test
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Root directory of the repository
DIST=$(cd "$HERE"/..; pwd)
IMAGE=${1:-softprops/lambda-rust}

source "${HERE}"/bashtest.sh

# test packaging with a single binary
package_bin() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -u $(id -u):$(id -g) \
    -e BIN="$1" \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    ${IMAGE} && \
    ls target/lambda/release/"${1}".zip > /dev/null 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

# test packaging all binaries
package_all() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -u $(id -u):$(id -g) \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    ${IMAGE} && \
    ls target/lambda/release/"${1}".zip > /dev/null 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

# test PACKAGE=false flag
compile_without_packaging() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -u $(id -u):$(id -g) \
    -e PACKAGE=false \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    ${IMAGE} &&
    !(ls target/lambda/release/"${1}".zip > /dev/null 2>&1) &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

# test packaging with PROFILE=dev
package_all_dev_profile() {
    rm -rf target/lambda/debug > /dev/null 2>&1
    docker run --rm \
    -u $(id -u):$(id -g) \
    -e PROFILE=dev \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    ${IMAGE} && \
    ls target/lambda/debug/"${1}".zip > /dev/null 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

for project in test-func test-multi-func test-func-with-hooks; do
    cd "${HERE}"/"${project}"
    echo "👩‍🔬 Running tests for $project with image $IMAGE"

    if [[ "$project" == test-multi-func ]]; then
        bin_name=test-func
    else
        bin_name=bootstrap
    fi

    # package tests
    assert "it packages single bins" package_bin "${bin_name}"

    assert "it packages all bins with dev profile" package_all_dev_profile "${bin_name}"

    assert "it compiles the binaries without zipping when PACKAGE=false" compile_without_packaging "${bin_name}"

    assert "it packages all bins" package_all "${bin_name}"

    # verify packaged artifact by invoking it using the lambdaci "provided" docker image
    rm -f output.log > /dev/null 2>&1
    rm -f test-out.log > /dev/null 2>&1
    rm -rf /tmp/lambda > /dev/null 2>&1
    unzip -o \
        target/lambda/release/"${bin_name}".zip \
        -d /tmp/lambda > /dev/null 2>&1 && \
    docker run \
        -i -e DOCKER_LAMBDA_USE_STDIN=1 \
        --rm \
        -v /tmp/lambda:/var/task \
        lambci/lambda:provided < test-event.json | grep -v RequestId | grep -v '^\W*$' > test-out.log

    assert "when invoked, it produces expected output" diff expected-output.json test-out.log
done

end_tests

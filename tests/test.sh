#!/usr/bin/env bash

# Directory of the integration test
HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
: "${IMAGE:=rustserverless/lambda-rust:lastest-arm64}"

source "${HERE}"/bashtest.sh

# test packaging with a single binary
package_bin() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -u "$(id -u)":"$(id -g)" \
    -e BIN="$1" \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    "${IMAGE}" && \
    ls target/lambda/release/"${1}".zip > /dev/null 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

# test packaging all binaries
package_all() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -u "$(id -u)":"$(id -g)" \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    "${IMAGE}" && \
    ls target/lambda/release/"${1}".zip > /dev/null 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

# test PACKAGE=false flag
compile_without_packaging() {
    rm -rf target/lambda/release > /dev/null 2>&1
    docker run --rm \
    -u "$(id -u)":"$(id -g)" \
    -e PACKAGE=false \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    "${IMAGE}" &&
    ! (ls target/lambda/release/"${1}".zip > /dev/null 2>&1) &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

# test packaging with PROFILE=dev
package_all_dev_profile() {
    rm -rf target/lambda/debug > /dev/null 2>&1
    docker run --rm \
    -u "$(id -u)":"$(id -g)" \
    -e PROFILE=dev \
    -v "${PWD}":/code \
    -v "${HOME}"/.cargo/registry:/cargo/registry \
    -v "${HOME}"/.cargo/git:/cargo/git \
    "${IMAGE}" && \
    ls target/lambda/debug/"${1}".zip > /dev/null 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap 2>&1 &&
    ls target/lambda/release/output/"${1}"/bootstrap.debug 2>&1
}

verify_packaged_application() {
    LAMBDA_RUNTIME_DIR="/var/runtime"
    LAMBDA_TASK_DIR="/var/task"
    HOOKS="test-func-with-hooks"
    TRY=1
    MAX_TRY=10
    TRIES_EXCEEDED=10
    SLEEP=1
    PACKAGE="${1}"
    PROJECT="${2}"
    TSFRACTION=$(date +%M%S)

    clean_up() {
        docker container stop lamb > /dev/null 2>&1
        rm -f bootstrap > /dev/null 2>&1
        rm -f output.log > /dev/null 2>&1
    }

    clean_up
    rm -f test-out.log > /dev/null 2>&1

    unzip -o \
           target/lambda/release/"${PACKAGE}".zip

    if [ "$PROJECT" = "${HOOKS}" ]; then
        docker build -t mylambda:"${TSFRACTION}" -f- . <<EOF
FROM public.ecr.aws/lambda/provided:al2
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
COPY output.log ${LAMBDA_TASK_DIR}
CMD [ "function.handler" ]
EOF
    else
        docker build -t mylambda:"${TSFRACTION}" -f- . <<EOF
FROM public.ecr.aws/lambda/provided:al2
COPY bootstrap ${LAMBDA_RUNTIME_DIR}
CMD [ "function.handler" ]
EOF
    fi
    # rm -f bootstrap > /dev/null 2>&1
    docker run \
        --name lamb \
        --rm \
        -p 9000:8080 \
        -d mylambda:"${TSFRACTION}"

    until curl -X POST \
        -H "Content-Type: application/json" \
        -d "@test-event.json" \
        "http://localhost:9000/2015-03-31/functions/function/invocations" | \
        grep -v RequestId | \
        grep -v '^\W*$' > test-out.log; do
      >&2 echo "waiting for service to spin up"
      sleep ${SLEEP}
      if [ ${TRY} = ${MAX_TRY} ]; then
        exit ${TRIES_EXCEEDED}
        else
        TRY=$((TRY + 1))
        fi
    done

    clean_up
}

for project in test-func test-multi-func test-func-with-hooks; do
    cd "${HERE}"/"${project}" || exit 2
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

    # verify packaged artifact by invoking it using the aws lambda "provided.al2" docker image
    verify_packaged_application "${bin_name}" "${project}"
    assert "when invoked, it produces expected output" diff expected-output.json test-out.log
done

end_tests

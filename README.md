# AWS Lambda [Rust](https://www.rust-lang.org/) docker builder 🐑 🐳 🦀 [![Build Status](https://github.com/softprops/lambda-rust/workflows/Main/badge.svg)](https://github.com/softprops/lambda-rust/actions)


## 🤔 about

This docker image extends [lambda ci `provided`](https://github.com/lambci/docker-lambda#documentation) builder docker image, a faithful reproduction of the actual AWS "**provided**" Lambda runtime environment,
and installs [rustup](https://rustup.rs/) and the *stable* rust toolchain.

## 📦 install

Tags for this docker image follow the naming convention `softprops/lambda-rust:{version}-rust-{rust-stable-version}`
where `{rust-stable-version}` is a stable version of rust.

You can find a list of available docker tags [here](https://hub.docker.com/r/softprops/lambda-rust/tags)

> 💡 If you don't find the version you're looking for, please [open a new github issue](https://github.com/softprops/lambda-rust/issues/new?title=I%27m%20looking%20for%20version%20xxx) to publish one

You can also depend directly on `softprops/lambda-rust:latest` for the most recently published version.

## 🤸 usage

The default docker entrypoint will build a packaged release optimized version your Rust artifact under `target/lambda/release` to
isolate the lambda specific build artifacts from your host-local build artifacts.

> **⚠️ Note:** you can switch from the `release` profile to a custom profile like `dev` by providing a `PROFILE` environment variable set to the name of the desired profile. i.e. `-e PROFILE=dev` in your docker run

> **⚠️ Note:** you can include debug symbols in optimized release build binaries by setting `DEBUGINFO`. By default, debug symbols will be stripped from the release binary and set aside in a separate .debug file.

You will want to volume mount `/code` to the directory containing your cargo project.

You can pass additional flags to `cargo`, the Rust build tool, by setting the `CARGO_FLAGS` docker env variable

A typical docker run might look like the following.

```sh
$ docker run --rm \
    -v ${PWD}:/code \
    -v ${HOME}/.cargo/registry:/root/.cargo/registry \
    -v ${HOME}/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust
```

> 💡 The -v (volume mount) flags for `/root/.cargo/{registry,git}` are optional but when supplied, provides a much faster turn around when doing iterative development

If you are using Windows, the command above may need to be modified to include
a `BIN` environment variable set to the name of the binary to be build and packaged

```sh
$ docker run --rm \
    -e BIN={your-binary-name} \
    -v ${PWD}:/code \
    -v ${HOME}/.cargo/registry:/root/.cargo/registry \
    -v ${HOME}/.cargo/git:/root/.cargo/git \
    softprops/lambda-rust
```

If you're suffering from poor performance on Windows, you can enable a separate build volume
to speed up file access. Initial setup requires creating a docker volume with the following command.
```sh
$ docker volume create rust-build-volume
```
Now you can run the build with the following command and both clean and incremental builds
should be way faster.
```sh
$ docker run --rm \
    -e BIN={your-binary-name} \
    -v ${PWD}:/code \
    -v rust-build-volume:/build-volume \
    softprops/lambda-rust
```

## 🤸🤸 usage via cargo aws-lambda subcommand

If you want to set up ad hoc lambda functions or have another reason to not to go with full blown devops orchestration tools,
there's a cargo subcommand to compile your code into a zip file and deploy it to an existing function. This comes with only
rust and docker as dependencies.

Setup
```sh
$ cargo install cargo-aws-lambda
```

To compile and deploy in your project directory
```sh
$ cargo aws-lambda {your aws function's full ARN} {your-binary-name}
```

> 💡 Add `--use-build-volume` to get speed up on Windows

To list all options 
```sh
$ cargo aws-lambda --help
```

More instructions can be found [here](https://github.com/vvilhonen/cargo-aws-lambda).

## 🔬 local testing

Once you've built a Rust lambda function artifact, the `provided` runtime expects
deployments of that artifact to be named "**bootstrap**". The `lambda-rust` docker image
builds a zip file, named after the binary, containing your binary files renamed to "bootstrap"

You can invoke this bootstap executable with the lambda-ci docker image for the `provided` AWS lambda runtime.

```sh
# start a docker container replicating the "provided" lambda runtime
# awaiting an event to be provided via stdin
$ unzip -o \
    target/lambda/release/{your-binary-name}.zip \
    -d /tmp/lambda && \
  docker run \
    -i -e DOCKER_LAMBDA_USE_STDIN=1 \
    --rm \
    -v /tmp/lambda:/var/task \
    lambci/lambda:provided

# provide an event payload via stdin (typically a json blob)

# Ctrl-D to yield control back to your function
```

Doug Tangren (softprops) 2018

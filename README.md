# lambda rust docker builder 🐳 🦀

## 🤔 about

This image extends [lambda ci `provided`](https://github.com/lambci/docker-lambda#documentation) builder docker image, a faithful reproduction of the actual AWS provided lambda runtime environment,
and installs [rustup](https://rustup.rs/) and the *stable* rust toolchain.

## 📦 install

Tags for this docker follow the convention `softprops/lambda-rust:{version}-rust-{rust-stable-version}'
Where rust-version is a stable version of rust.

You can find a list of available docker tags [here](https://hub.docker.com/r/softprops/lambda-rust/)

You can also depend directly on `softprops/lambda-rust:latest` for the most recently published version.

## 🤸 usage

The default docker command will build a release version your rust application under `target/lambda/release` to
isolate the lambda specific build artifacts from your localhost build artifacts.

You will want to volume mount `/code` to the directory containing your cargo project.

You can pass additional flags to cargo by setting the `CARGO_FLAGS` docker env variable

A typical docker run might look like the following

```bash
$ docker run --rm \
	-v ${PWD}:/code \
	-v ${HOME}/.cargo/registry:/root/.cargo/registry \
	-v ${HOME}/.cargo/git:/root/.cargo/git \
	softprops/lambda-rust:{tag}
```


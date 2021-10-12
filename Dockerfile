#
# This Dockerfile sole purpose is to compile and package AWS lambda functions
# using the rust runtime within a serverless framework project.
#
# https://github.com/lambci/docker-lambda#documentation
FROM lambci/lambda:build-provided.al2

ARG RUST_VERSION=1.55.0
RUN yum install -y jq openssl-devel openssh-client git
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | CARGO_HOME=/cargo RUSTUP_HOME=/rustup sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION
ADD build.sh /usr/local/bin/
VOLUME ["/code"]
WORKDIR /code
# This is necessary to prevent the "git clone" operation from failing
# with an "unknown host key" error.
RUN mkdir -m 700 /root/.ssh
RUN touch -m 600 /root/.ssh/known_hosts
RUN ssh-keyscan github.com > /root/.ssh/known_hosts
# This is as far as we go here, the rest is done late

ENTRYPOINT ["/usr/local/bin/build.sh"]

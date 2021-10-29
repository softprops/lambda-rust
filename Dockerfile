#
# This Dockerfile sole purpose is to compile and package AWS lambda functions
# using the rust runtime within a serverless framework project.
#
# https://github.com/lambci/docker-lambda#documentation
FROM lambci/lambda:build-provided.al2

RUN yum install -y jq openssl-devel openssh-client git
ARG RUST_VERSION=1.56.0
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

RUN cd /tmp \
      && curl --location \
      https://github.com/mozilla/sccache/releases/download/v0.2.15/sccache-v0.2.15-x86_64-unknown-linux-musl.tar.gz \
      | tar --extract --gunzip \
      && chmod a+x sccache-v0.2.15-x86_64-unknown-linux-musl/sccache \
      && mv sccache-v0.2.15-x86_64-unknown-linux-musl/sccache /usr/local/bin/sccache

ADD /sccache-wrapper.sh /usr/local/bin/
ENV RUSTC_WRAPPER=sccache-wrapper.sh
# This is as far as we go here, the rest is done late

ENTRYPOINT ["/usr/local/bin/build.sh"]

# https://github.com/lambci/docker-lambda#documentation
FROM lambci/lambda:build-provided
ARG RUST_VERSION
RUN yum install -y jq
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
 | sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION
ADD build.sh /usr/local/bin/
VOLUME ["/code"]
WORKDIR /code
ENTRYPOINT ["/usr/local/bin/build.sh"]
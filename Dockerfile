# https://github.com/lambci/docker-lambda#documentation
FROM lambci/lambda:build-provided
ARG RUST_VERSION
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain $RUST_VERSION
ADD build.sh /usr/local/bin/
VOLUME ["/code"]
WORKDIR /code
ENTRYPOINT ["/usr/local/bin/build.sh"]
# https://github.com/ilianaw/rust-crowbar/issues/20
# https://github.com/lambci/docker-lambda#documentation
FROM lambci/lambda:build-provided
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain 1.30.1
ADD build.sh /usr/local/bin/
VOLUME ["/code"]
WORKDIR /code
ENTRYPOINT ["/usr/local/bin/build.sh"]
FROM public.ecr.aws/lambda/provided:al2

ARG RUST_VERSION=1.54.0
RUN yum -y update
RUN yum -y remove kernel-devel-4.14.203-156.332.amzn2
RUN yum install -y jq openssl-devel
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | CARGO_HOME=/cargo RUSTUP_HOME=/rustup sh -s -- -y --profile minimal --default-toolchain $RUST_VERSION
ADD build.sh /usr/local/bin/
ADD latest.sh /usr/local/bin/
VOLUME ["/code"]
WORKDIR /code
ENTRYPOINT ["/usr/local/bin/build.sh"]

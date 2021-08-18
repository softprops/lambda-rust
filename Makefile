DOCKER ?= docker
VERSION ?= 0.4.0
RUST_VERSION ?= 1.54.0
REPO ?= rustserverless/lambda-rust
TAG ?= "$(REPO):$(VERSION)-rust-$(RUST_VERSION)"

publish: build
	$(DOCKER) push $(TAG)
	$(DOCKER) push $(REPO):latest

build:
	$(DOCKER) build --build-arg RUST_VERSION=$(RUST_VERSION) -t $(TAG) .
	$(DOCKER) tag $(TAG) $(REPO):latest

test:
	@tests/test.sh

debug: build
	$(DOCKER) run --rm -it \
		-u $(id -u):$(id -g) \
		-v ${PWD}:/code:Z \
		-v ${HOME}/.cargo/registry:/cargo/registry \
		-v ${HOME}/.cargo/git:/cargo/git  \
		--entrypoint=/bin/bash \
		$(REPO)

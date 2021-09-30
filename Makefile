DOCKER ?= docker
INPUT_RELEASE_VERSION ?= 0.4.0
RUST_VERSION ?= 1.55.0
REPO ?= rustserverless/lambda-rust
TAG ?= latest

publish: build
	$(DOCKER) push $(REPO):${TAG}

publish-tag: build publish
	$(DOCKER) tag $(REPO):${TAG} "$(REPO):$(INPUT_RELEASE_VERSION)-rust-$(RUST_VERSION)"
	$(DOCKER) push "$(REPO):$(INPUT_RELEASE_VERSION)-rust-$(RUST_VERSION)"

build:
	$(DOCKER) build --build-arg RUST_VERSION=$(RUST_VERSION) -t $(REPO):${TAG} .

test:
	@tests/test.sh

debug: build
	$(DOCKER) run --rm -it \
		-u $(id -u):$(id -g) \
		-v ${PWD}:/code:Z \
		-v ${HOME}/.cargo/registry:/cargo/registry \
		-v ${HOME}/.cargo/git:/cargo/git  \
		--entrypoint=/bin/bash \
		$(REPO):$(TAG)

check: 
	$(DOCKER) run --rm \
		--entrypoint=/usr/local/bin/latest.sh \
		$(REPO)
		
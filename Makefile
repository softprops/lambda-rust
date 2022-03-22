DOCKER ?= docker
INPUT_RELEASE_VERSION ?= 0.4.0
RUST_VERSION ?= 1.59.0
REPO ?= rustserverless/lambda-rust
TAG ?= latest

publish: build
	$(DOCKER) push $(REPO):${TAG}

publish-arm64: build-arm64
	$(DOCKER) push $(REPO):${TAG}-arm64

publish-tag: build publish
	$(DOCKER) tag $(REPO):${TAG} "$(REPO):$(INPUT_RELEASE_VERSION)-rust-$(RUST_VERSION)"
	$(DOCKER) push "$(REPO):$(INPUT_RELEASE_VERSION)-rust-$(RUST_VERSION)"

publish-tag-arm64: build-arm64 publish-arm64
	$(DOCKER) tag "$(REPO):${TAG}-arm64" "$(REPO):$(INPUT_RELEASE_VERSION)-rust-$(RUST_VERSION)-arm64"
	$(DOCKER) push "$(REPO):$(INPUT_RELEASE_VERSION)-rust-$(RUST_VERSION)-arm64"

build:
	$(DOCKER) build --build-arg RUST_VERSION=$(RUST_VERSION) -t $(REPO):${TAG} .

build-arm64:
	$(DOCKER) build --build-arg RUST_VERSION=$(RUST_VERSION) -t "$(REPO):${TAG}-arm64" -f Dockerfile_arm64 .

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

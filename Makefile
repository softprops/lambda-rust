VERSION ?= 0.3.0
RUST_VERSION ?= 1.45.2
REPO ?= softprops/lambda-rust
TAG ?= "$(REPO):$(VERSION)-rust-$(RUST_VERSION)"

publish: build
	@docker push $(TAG)
	@docker push $(REPO):latest

build:
	@docker build --build-arg RUST_VERSION=$(RUST_VERSION) -t $(TAG) .
	@docker tag $(TAG) $(REPO):latest

test: build
	@tests/test.sh

debug: build
	@docker run --rm -it \
		-u $(id -u):$(id -g) \
		-v ${PWD}:/code \
		-v ${HOME}/.cargo/registry:/cargo/registry \
		-v ${HOME}/.cargo/git:/cargo/git  \
		--entrypoint=/bin/bash \
		$(REPO)

VERSION ?= 0.2.7
RUST_VERSION ?= 1.44.0
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
		-v ${PWD}:/code \
		-v ${HOME}/.cargo/registry:/root/.cargo/registry \
		-v ${HOME}/.cargo/git:/root/.cargo/git  \
		--entrypoint=/bin/bash \
		$(REPO)
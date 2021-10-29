VERSION ?= 0.6.0
RUST_VERSION ?= 1.56.0
REPO ?= scoots/lambda-rust
TAG ?= "$(REPO):$(VERSION)-rust-$(RUST_VERSION)"

publish: build
	@docker push $(TAG)
	@docker push $(REPO):rust-$(RUST_VERSION)
	@docker push $(REPO):latest

build:
	@docker build --build-arg RUST_VERSION=$(RUST_VERSION) --tag $(TAG) .
	@docker tag $(TAG) $(REPO):rust-$(RUST_VERSION)
	@docker tag $(TAG) $(REPO):latest

test: build
	@tests/test.sh

debug: build
	@docker run \
		--rm \
		--interactive \
		--tty \
		--user $(id -u):$(id -g) \
		--volume ${PWD}:/code \
		--volume ${HOME}/.cargo/registry:/cargo/registry \
		--volume ${HOME}/.cargo/git:/cargo/git  \
		--entrypoint=/bin/bash \
		$(REPO)

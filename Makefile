VERSION ?= 0.2.0
RUST_VERSION ?= 1.32.0
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

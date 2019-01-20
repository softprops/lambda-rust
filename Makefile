VERSION ?= 0.2.0
RUST_VERSION ?= 1.31.2
REPO ?= softprops/lambda-rust
TAG ?= "$(REPO):$(VERSION)-rust-$(RUST_VERSION)"

publish: build
	docker push $(TAG)
	docker push $(REPO):latest

build:
	docker build -t $(TAG) .
	docker tag $(TAG) $(REPO):latest
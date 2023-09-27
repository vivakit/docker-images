TAG_COMMIT := $(shell git rev-list --abbrev-commit --tags --max-count=1)
TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
COMMIT := $(shell git rev-parse --short HEAD)
COMMIT_SHA := $(shell git rev-parse HEAD)
DATE := $(shell git log -1 --format=%cd --date=format:"%Y%m%d")
VERSION := $(TAG:v%=%)
ifneq ($(COMMIT), $(TAG_COMMIT))
    VERSION := $(VERSION)-next-$(COMMIT)-$(DATE)
endif
ifeq ($(VERSION),)
    VERSION := $(COMMIT)-$(DATE)
endif
ifneq ($(shell git status --porcelain),)
    VERSION := $(VERSION)-dirty
endif

VERSION = $(COMMIT_SHA)

build-all: build-debian build-ubuntu build-debian-backup-postgresql-to-b2
push-all: push-debian push-ubuntu push-debian-backup-postgresql-to-b2

.PHONY: build-debian
build-debian:
	docker buildx build --push --platform linux/amd64,linux/arm64 \
	./debian-asdf-erlang-elixir-nodejs \
	-t vivakit/debian-asdf-erlang-elixir-nodejs:$(VERSION) \
	--cache-to type=registry,ref=vivakit/debian-asdf-erlang-elixir-nodejs:buildcache \
  --cache-from type=registry,ref=vivakit/debian-asdf-erlang-elixir-nodejs:buildcache \
	--progress=plain

.PHONY: build-debian-backup-postgresql-to-b2
build-debian-backup-postgresql-to-b2:
	docker buildx build --platform linux/amd64,linux/arm64 ./debian-backup-postgresql-to-b2 -t vivakit/debian-backup-postgresql-to-b2:$(VERSION) --progress=plain

.PHONY: build-ubuntu
build-ubuntu:
	docker buildx build --platform linux/amd64,linux/arm64 ./ubuntu-asdf-erlang-elixir-nodejs -t vivakit/ubuntu-asdf-erlang-elixir-nodejs:$(VERSION) --progress=plain

.PHONY: push-debian
push-debian:
	docker push vivakit/debian-asdf-erlang-elixir-nodejs:$(VERSION)

.PHONY: push-debian-backup-postgresql-to-b2
push-debian-backup-postgresql-to-b2:
	docker push vivakit/debian-backup-postgresql-to-b2:$(VERSION)

.PHONY: push-ubuntu
push-ubuntu:
	docker push vivakit/ubuntu-asdf-erlang-elixir-nodejs:$(VERSION)

# git tag -a 'v0.0.9' -m "v0.0.9"

TAG_COMMIT := $(shell git rev-list --abbrev-commit --tags --max-count=1)
TAG := $(shell git describe --abbrev=0 --tags ${TAG_COMMIT} 2>/dev/null || true)
COMMIT := $(shell git rev-parse --short HEAD)
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

build-all: build-debian build-ubuntu build-debian-backup-postgresql-to-b2

.PHONY: build-debian
build-debian:
	docker build ./debian-asdf-erlang-elixir-nodejs -t vivakit/debian-asdf-erlang-elixir-nodejs:$(VERSION) --progress=plain

.PHONY: build-debian-backup-postgresql-to-b2
build-debian-backup-postgresql-to-b2:
	docker build ./debian-backup-postgresql-to-b2 -t vivakit/debian-backup-postgresql-to-b2:$(VERSION) --progress=plain

.PHONY: build-ubuntu
build-ubuntu:
	docker build ./ubuntu-asdf-erlang-elixir-nodejs -t vivakit/ubuntu-asdf-erlang-elixir-nodejs:$(VERSION) --progress=plain

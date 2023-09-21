.PHONY: all mac linux run

ARCH := $(shell uname -m)

ifeq ($(ARCH),x86_64)
    DOCKER_PLATFORM=linux/amd64
    BUILD_ARG_ARCH=amd64
else ifeq ($(ARCH),arm64)
    DOCKER_PLATFORM=linux/arm64
    BUILD_ARG_ARCH=arm64
else
    $(error Unsupported architecture $(ARCH))
endif

mac:
	docker buildx build --platform linux/arm64 -t klmnops:latest .

linux:
	docker buildx build --platform linux/amd64 --build-arg ARCH=amd64 -t klmnops:latest .

run:
	docker run -ti --rm -v ~/.aws:/.aws:ro klmnops:latest
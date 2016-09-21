all: build

build:
	@docker build --tag=oomathias/gitlab-ci-multi-runner .

release: build
	@docker build --tag=oomathias/gitlab-ci-multi-runner:$(shell cat VERSION) .

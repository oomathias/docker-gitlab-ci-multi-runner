all: build

%:
  @:

build:
	@docker build --tag=oomathias/gitlab-ci-multi-runner .

squash: build
	@docker save oomathias/gitlab-ci-multi-runner | sudo docker-squash | docker load

release: build
	@docker tag oomathias/gitlab-ci-multi-runner oomathias/gitlab-ci-multi-runner:$(shell cat VERSION)

run: build
	@docker run --rm=true -it oomathias/gitlab-ci-multi-runner $(filter-out $@,$(MAKECMDGOALS))

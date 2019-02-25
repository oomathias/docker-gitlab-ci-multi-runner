FROM gitlab/gitlab-runner:alpine-v11.8.0
MAINTAINER Mathias Beugnon <mathias@beugnon.fr>

ARG VCS_REF
ARG BUILD_DATE

ENV GITLAB_RUNNER_VERSION="11.8.0" \
    DOCKER_COMPOSE_VERSION="1.23.2" \
    RUNNER_CONCURRENT='' \
    CI_SERVER_URL='' \
    RUNNER_TOKEN='' \
    RUNNER_EXECUTOR='docker' \
    RUNNER_DESCRIPTION='' \
    RUNNER_DOCKER_IMAGE='docker:latest' \
    RUNNER_DOCKER_MODE='socket' \
    RUNNER_DOCKER_PRIVATE_REGISTRY_URL='' \
    RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN='' \
    RUNNER_DOCKER_ADDITIONAL_VOLUME='' \
    RUNNER_OUTPUT_LIMIT='4096' \
    RUNNER_AUTOUNREGISTER='true'

LABEL org.label-schema.name="docker-gitlab-runner" \
      org.label-schema.url="https://github.com/oomathias/docker-gitlab-runner" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.vcs-url="https://github.com/oomathias/docker-gitlab-runner" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      com.gitlab.gitlab_runner=$GITLAB_RUNNER_VERSION \
      com.gitlab.docker-compose=$DOCKER_COMPOSE_VERSION \
      org.label-schema.schema-version="1.0"

# Install packages
RUN echo " ---> Upgrading OS and installing dependencies" \
  && apk --update upgrade \
  && apk add --no-cache \
    docker \
    openrc \
    openssh-client \
    openssl \
    sudo \
  && echo " ---> Installing docker-compose (${DOCKER_COMPOSE_VERSION})" \
  && wget -q https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 -O /usr/bin/docker-compose \
  && chmod +x /usr/bin/docker-compose \
  && echo " ---> Cleaning" \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/*

COPY entrypoint /
RUN chmod +x /entrypoint

VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
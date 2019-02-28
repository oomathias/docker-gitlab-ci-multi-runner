FROM gitlab/gitlab-runner:alpine-v11.8.0
MAINTAINER Mathias Beugnon <mathias@beugnon.fr>

ENV GITLAB_RUNNER_VERSION="11.8.0" \
    RUNNER_CONCURRENCY='' \
    CI_SERVER_URL='' \
    REGISTRATION_TOKEN='' \
    RUNNER_EXECUTOR='docker' \
    DOCKER_IMAGE='docker:latest' \
    DOCKER_MODE='socket' \
    RUNNER_AUTOUNREGISTER='true' \
    DEBUG=''

COPY entrypoint /

RUN echo " ---> Install dependencies" \
  && apk add --no-cache \
    openrc \
    openssh-client \
    sudo \
  && echo " ---> Cleaning" \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \
  && chmod +x /entrypoint

WORKDIR /home/gitlab-runner
VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint"]
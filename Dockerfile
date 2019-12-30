FROM gitlab/gitlab-runner:alpine-v12.6.0
LABEL Mathias Beugnon <mathias@beugnon.fr>

ENV GITLAB_RUNNER_VERSION="12.6.0" \
  CA_CERTIFICATES_PATH='' \
  CI_SERVER_URL='' \
  DOCKER_IMAGE='docker:latest' \
  DOCKER_MODE='dind' \
  REGISTRATION_TOKEN='' \
  RUNNER_AUTOUNREGISTER='true' \
  RUNNER_CHECK_INTERVAL='3' \
  RUNNER_CONCURRENCY='' \
  RUNNER_ENV='' \
  RUNNER_EXECUTOR='docker' \
  RUNNER_NAME='runner' \
  RUNNER_SESSION_TIMEOUT='1800' \
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

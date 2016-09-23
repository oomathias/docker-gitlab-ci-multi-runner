FROM alpine:latest
MAINTAINER mathias@beugnon.fr

ENV GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

RUN apk --no-cache --update add \
  bash \
  ca-certificates \
  curl \
  docker \
  git \
  grep \
  libc6-compat \
  openrc \
  openssh-client \
  openssl \
  sudo \
  tar \
  unzip \
  vim \
  wget

# add dumb-init
RUN curl -s https://api.github.com/repos/Yelp/dumb-init/releases \
  | grep browser_download_url | grep amd64 | head -n 1 | cut -d '"' -f 4 | \
  wget -q -i - -O /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# add glibc
RUN curl -s https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases \
  | grep browser_download_url | grep .apk | grep -v unreleased | grep -v bin | grep -v i18n \
  | head -n 1 | cut -d '"' -f 4 | \
  wget -q -i - -O glibc.apk \
  && apk add --allow-untrusted glibc.apk \
  && rm -r glibc.apk

# add gitlab-ci-multi-runner
RUN wget -q -O /usr/local/bin/gitlab-ci-multi-runner https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-ci-multi-runner-linux-amd64 && \
  chmod +x /usr/local/bin/gitlab-ci-multi-runner && \
	ln -s /usr/local/bin/gitlab-ci-multi-runner /usr/local/bin/gitlab-runner

# add git user
RUN adduser -D -s /bin/false -g 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER}
RUN sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -s ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh

# add rancher-compose
RUN wget -q https://releases.rancher.com/compose/latest/rancher-compose-linux-amd64.tar.gz \
  && mkdir rancher-compose \
	&& tar -xvzf rancher-compose-linux-amd64.tar.gz -C rancher-compose --strip-components=2 \
	&& mv rancher-compose/rancher-compose /usr/local/bin/rancher-compose \
	&& chmod +x /usr/local/bin/rancher-compose \
	&& rm -r rancher-compose rancher-compose-linux-amd64.tar.gz

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"

ENTRYPOINT ["/usr/local/bin/dumb-init", "/entrypoint.sh"]

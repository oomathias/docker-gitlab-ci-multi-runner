FROM alpine:latest
MAINTAINER Mathias Beugnon <mathias@beugnon.fr>

ARG VCS_REF
ARG BUILD_DATE

ENV DUMB_INIT_VERSION="1.2.0" \
    GLIBC_VERSION="2.23-r3" \
    RANCHER_COMPOSE_VERSION="0.12.1" \
    GITLAB_CI_MULTI_RUNNER_VERSION="1.9.1" \
    GITLAB_CI_MULTI_RUNNER_USER=gitlab_ci_multi_runner \
    GITLAB_CI_MULTI_RUNNER_HOME_DIR="/home/gitlab_ci_multi_runner"
ENV GITLAB_CI_MULTI_RUNNER_DATA_DIR="${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/data"

LABEL org.label-schema.name="docker-gitlab-ci-multi-runner" \
      org.label-schema.url="https://github.com/oomathias/docker-gitlab-ci-multi-runner" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.vcs-url="https://github.com/oomathias/docker-gitlab-ci-multi-runner" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.schema-version="1.0" \

      com.gitlab.gitlab_ci_multi_runner=$GITLAB_CI_MULTI_RUNNER_VERSION \
      com.yelp.dumb-init=$DUMB_INIT_VERSION \
      com.sgerrand.alpine-pkg-glibc=$GLIBC_VERSION \
      com.rancher.compose=$RANCHER_COMPOSE_VERSION

# Install packages
RUN \
  # tmp
  echo " ---> Upgrading OS and installing dependencies" \
  && TMP_APK='curl grep tar' \
  && apk --update upgrade \
  && apk add $TMP_APK \
    bash \
    ca-certificates \
    docker \
    git \
    openrc \
    openssh-client \
    openssl \
    sudo \

  # dumb-init
  && echo " ---> Installing dumb-init (${DUMB_INIT_VERSION})" \
  && >&2 echo "dumb-init_${DUMB_INIT_VERSION}_amd64" \
  && curl -#LOS https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 \
  && >&2 echo "sha256sums" \
  && curl -#LOS https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/sha256sums \
  && fgrep "dumb-init_${DUMB_INIT_VERSION}_amd64$" sha256sums | sha256sum -c - \
  && mv dumb-init_${DUMB_INIT_VERSION}_amd64 /usr/local/bin/dumb-init \
  && chmod +x /usr/local/bin/dumb-init \
  && rm sha256sums \

  # glibc
  && echo " ---> Installing glibc (${GLIBC_VERSION})" \
  && >&2 echo "glibc-${GLIBC_VERSION}.apk" \
  && curl -#LOS https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && >&2 echo "sgerrand.rsa.pub" \
  && curl -#LS -o /etc/apk/keys/sgerrand.rsa.pub https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/sgerrand.rsa.pub \
  && apk add glibc-${GLIBC_VERSION}.apk \
  && rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk \

  # gitlab-ci-multi-runner
  && echo " ---> Installing gitlab-ci-multi-runner (${GITLAB_CI_MULTI_RUNNER_VERSION})" \
  && >&2 echo "gitlab-ci-multi-runner-linux-amd64" \
  && curl -#LS -o /usr/local/bin/gitlab-ci-multi-runner https://gitlab-ci-multi-runner-downloads.s3.amazonaws.com/v${GITLAB_CI_MULTI_RUNNER_VERSION}/binaries/gitlab-ci-multi-runner-linux-amd64 \
  && chmod +x /usr/local/bin/gitlab-ci-multi-runner \
  && ln -s /usr/local/bin/gitlab-ci-multi-runner /usr/local/bin/gitlab-runner \

  # rancher-compose
  && echo " ---> Installing rancher-compose (${RANCHER_COMPOSE_VERSION})" \
  && >&2 echo "rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz" \
  && curl -#LOS https://releases.rancher.com/compose/v${RANCHER_COMPOSE_VERSION}/rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz \
  && mkdir rancher-compose \
  && tar -xvzf rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz -C rancher-compose --strip-components=2 \
  && mv rancher-compose/rancher-compose /usr/local/bin/rancher-compose \
  && chmod +x /usr/local/bin/rancher-compose \
  && rm -r rancher-compose rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz \

  # cleanup tmp
  && echo " ---> Cleaning" \
  && apk del --purge $TMP_APK \
  && rm -rf /var/cache/apk/* \
  && rm -rf /tmp/* \

  && echo " ---> Config" \
  && adduser -D -s /bin/false -g 'GitLab CI Runner' ${GITLAB_CI_MULTI_RUNNER_USER} \
  && sudo -HEu ${GITLAB_CI_MULTI_RUNNER_USER} ln -s ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/.ssh ${GITLAB_CI_MULTI_RUNNER_HOME_DIR}/.ssh

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME ["${GITLAB_CI_MULTI_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_CI_MULTI_RUNNER_HOME_DIR}"

ENTRYPOINT ["/usr/local/bin/dumb-init", "/entrypoint.sh"]

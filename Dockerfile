FROM alpine:latest
MAINTAINER Mathias Beugnon <mathias@beugnon.fr>

ARG VCS_REF
ARG BUILD_DATE

ENV DUMB_INIT_VERSION="1.2.2" \
    GLIBC_VERSION="2.28-r0" \
    RANCHER_COMPOSE_VERSION="0.12.5" \
    GITLAB_RUNNER_VERSION="11.6.0" \
    GITLAB_RUNNER_USER=gitlab_runner \
    GITLAB_RUNNER_HOME_DIR="/home/gitlab_runner"
ENV GITLAB_RUNNER_DATA_DIR="${GITLAB_RUNNER_HOME_DIR}/data"


ENV CA_CERTIFICATES_PATH=''
ENV RUNNER_CONCURRENT=''
ENV CI_SERVER_URL=''
ENV RUNNER_TOKEN=''
ENV RUNNER_EXECUTOR='docker'
ENV RUNNER_DESCRIPTION=''

ENV RUNNER_DOCKER_IMAGE='docker:latest'
ENV RUNNER_DOCKER_MODE='socket'
ENV RUNNER_DOCKER_PRIVATE_REGISTRY_URL=''
ENV RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN=''
ENV RUNNER_DOCKER_ADDITIONAL_VOLUME=''
ENV RUNNER_OUTPUT_LIMIT='4096'
ENV RUNNER_AUTOUNREGISTER='true'

LABEL org.label-schema.name="docker-gitlab-ci-multi-runner" \
      org.label-schema.url="https://github.com/oomathias/docker-gitlab-ci-multi-runner" \
      org.label-schema.docker.dockerfile="/Dockerfile" \
      org.label-schema.vcs-url="https://github.com/oomathias/docker-gitlab-ci-multi-runner" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.schema-version="1.0" \
      com.gitlab.gitlab_runner=$GITLAB_RUNNER_VERSION \
      com.yelp.dumb-init=$DUMB_INIT_VERSION \
      com.sgerrand.alpine-pkg-glibc=$GLIBC_VERSION \
      com.rancher.compose=$RANCHER_COMPOSE_VERSION

# Install packages
RUN echo " ---> Upgrading OS and installing dependencies" \
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
    sudo

# dumb-init
RUN echo " ---> Installing dumb-init (${DUMB_INIT_VERSION})" \
&& >&2 echo "dumb-init_${DUMB_INIT_VERSION}_amd64" \
&& curl -#LOS https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_amd64 \
&& >&2 echo "sha256sums" \
&& curl -#LOS https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/sha256sums \
&& sed -n '2p' sha256sums | sha256sum -c - \
&& mv dumb-init_${DUMB_INIT_VERSION}_amd64 /usr/local/bin/dumb-init \
&& chmod +x /usr/local/bin/dumb-init \
&& rm sha256sums

# glibc
RUN echo " ---> Installing glibc (${GLIBC_VERSION})" \
&& >&2 echo "glibc-${GLIBC_VERSION}.apk" \
&& curl -#LOS https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
&& >&2 echo "sgerrand.rsa.pub" \
&& curl -#LS -o /etc/apk/keys/sgerrand.rsa.pub https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/sgerrand.rsa.pub \
&& apk add glibc-${GLIBC_VERSION}.apk \
&& rm /etc/apk/keys/sgerrand.rsa.pub glibc-${GLIBC_VERSION}.apk

# gitlab-runner
RUN echo " ---> Installing gitlab-runner (${GITLAB_RUNNER_VERSION})" \
&& >&2 echo "gitlab-runner-linux-amd64" \
&& curl -#LS -o /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 \
&& chmod +x /usr/local/bin/gitlab-runner

# rancher-compose
RUN echo " ---> Installing rancher-compose (${RANCHER_COMPOSE_VERSION})" \
&& >&2 echo "rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz" \
&& curl -#LOS https://releases.rancher.com/compose/v${RANCHER_COMPOSE_VERSION}/rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz \
&& mkdir rancher-compose \
&& tar -xvzf rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz -C rancher-compose --strip-components=2 \
&& mv rancher-compose/rancher-compose /usr/local/bin/rancher-compose \
&& chmod +x /usr/local/bin/rancher-compose \
&& rm -r rancher-compose rancher-compose-linux-amd64-v${RANCHER_COMPOSE_VERSION}.tar.gz

# cleanup tmp
RUN echo " ---> Cleaning" \
&& apk del --purge $TMP_APK \
&& rm -rf /var/cache/apk/* \
&& rm -rf /tmp/*

# config
RUN echo " ---> Config" \
&& adduser -D -s /bin/false -g 'GitLab CI Runner' ${GITLAB_RUNNER_USER} \
&& sudo -HEu ${GITLAB_RUNNER_USER} ln -s ${GITLAB_RUNNER_DATA_DIR}/.ssh ${GITLAB_RUNNER_HOME_DIR}/.ssh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME ["${GITLAB_RUNNER_DATA_DIR}"]
WORKDIR "${GITLAB_RUNNER_HOME_DIR}"

ENTRYPOINT ["/usr/local/bin/dumb-init", "/entrypoint.sh"]

#!/bin/bash
set -e

CA_CERTIFICATES_PATH=${CA_CERTIFICATES_PATH:-$GITLAB_RUNNER_DATA_DIR/certs/ca.crt}

create_data_dir() {
  mkdir -p ${GITLAB_RUNNER_DATA_DIR}
  chown ${GITLAB_RUNNER_USER}:${GITLAB_RUNNER_USER} ${GITLAB_RUNNER_DATA_DIR}
}

generate_ssh_deploy_keys() {
  sudo -HEu ${GITLAB_RUNNER_USER} mkdir -p ${GITLAB_RUNNER_DATA_DIR}/.ssh/

  if [[ ! -e ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa || ! -e ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa.pub ]]; then
    echo "Generating SSH deploy keys..."
    rm -rf ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
    sudo -HEu ${GITLAB_RUNNER_USER} ssh-keygen -t rsa -N "" -f ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa

    echo ""
    echo -n "Your SSH deploy key is: "
    cat ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
    echo ""
  fi

  chmod 600 ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa ${GITLAB_RUNNER_DATA_DIR}/.ssh/id_rsa.pub
  chmod 700 ${GITLAB_RUNNER_DATA_DIR}/.ssh
  chown -R ${GITLAB_RUNNER_USER}:${GITLAB_RUNNER_USER} ${GITLAB_RUNNER_DATA_DIR}/.ssh/
}

update_ca_certificates() {
  if [[ -f ${CA_CERTIFICATES_PATH} ]]; then
    echo "Updating CA certificates..."
    cp "${CA_CERTIFICATES_PATH}" /usr/local/share/ca-certificates/ca.crt
    update-ca-certificates --fresh >/dev/null
  fi
}

grant_access_to_docker_socket() {
  if [ -S /var/run/docker.sock ]; then
    DOCKER_SOCKET_GID=$(stat -c %g /var/run/docker.sock)
    DOCKER_SOCKET_GROUP=$(stat -c %G /var/run/docker.sock)
    if [[ ${DOCKER_SOCKET_GROUP} == "UNKNOWN" ]]; then
      DOCKER_SOCKET_GROUP=docker
      addgroup -g ${DOCKER_SOCKET_GID} ${DOCKER_SOCKET_GROUP}
    fi
    adduser ${GITLAB_RUNNER_USER} ${DOCKER_SOCKET_GROUP}
  fi
}

configure_docker_credentials() {
  if [[ -n "${RUNNER_DOCKER_PRIVATE_REGISTRY_URL}" && -n "${RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN}" && ! -e "${GITLAB_RUNNER_HOME_DIR}/.docker/config.json" ]];then
    sudo -HEu ${GITLAB_RUNNER_USER} mkdir "${GITLAB_RUNNER_HOME_DIR}/.docker"
    sudo -HEu ${GITLAB_RUNNER_USER} \
    echo "{\"auths\": {\"${RUNNER_DOCKER_PRIVATE_REGISTRY_URL}\": {\"auth\": \"${RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN}\"}}}" > "${GITLAB_RUNNER_HOME_DIR}/.docker/config.json"
  fi
}

configure_ci_runner() {
  if [[ ! -e ${GITLAB_RUNNER_DATA_DIR}/config.toml ]]; then
    if [[ -n ${CI_SERVER_URL} && -n ${RUNNER_TOKEN} && -n ${RUNNER_DESCRIPTION} && -n ${RUNNER_EXECUTOR} ]]; then
      if [[ "${RUNNER_EXECUTOR}" == "docker" ]];then
        if [[ -n ${RUNNER_DOCKER_IMAGE} ]];then
          RUNNER_DOCKER_ARGS="--docker-privileged --docker-image ${RUNNER_DOCKER_IMAGE}"
        fi
        if [[ "${RUNNER_DOCKER_MODE}" == "socket" ]];then
          RUNNER_DOCKER_ARGS="$RUNNER_DOCKER_ARGS --docker-volumes /var/run/docker.sock:/var/run/docker.sock"
        fi
        if [[ -n ${RUNNER_DOCKER_ADDITIONAL_VOLUME} ]];then
          RUNNER_DOCKER_ARGS="$RUNNER_DOCKER_ARGS --docker-volumes ${RUNNER_DOCKER_ADDITIONAL_VOLUME}"
        fi
      fi
      sudo -HEu ${GITLAB_RUNNER_USER} \
        gitlab-runner register --config ${GITLAB_RUNNER_DATA_DIR}/config.toml \
          -n -u "${CI_SERVER_URL}" -r "${RUNNER_TOKEN}" --name "${RUNNER_DESCRIPTION}" --executor "${RUNNER_EXECUTOR}" \
          --output-limit "${RUNNER_OUTPUT_LIMIT}" \
          ${RUNNER_DOCKER_ARGS} \
          $(if [[ -n ${ENV_VARS} ]]; then ENV_VARS_TMP=($ENV_VARS); printf " --env %s" "${ENV_VARS_TMP[@]}"; fi)
          # --docker-label io.rancher.container.network=true
    else
      sudo -HEu ${GITLAB_RUNNER_USER} \
        gitlab-runner register --config ${GITLAB_RUNNER_DATA_DIR}/config.toml
    fi
    cat ${GITLAB_RUNNER_DATA_DIR}/config.toml
    if [[ -n ${RUNNER_CONCURRENT} ]];then
      sed -i "s/concurrent = .*/concurrent = ${RUNNER_CONCURRENT}/" ${GITLAB_RUNNER_DATA_DIR}/config.toml
    fi
    if [[ -n "${RANCHER_NETWORK}" ]]; then
      # add rancher network support
      # TODO: migrate to --docker-label when available
      sudo -HEu ${GITLAB_RUNNER_USER} \
        sed -i '/\[runners.docker\]/a\    dns = ["169.254.169.250"]' ${GITLAB_RUNNER_DATA_DIR}/config.toml
    fi
    echo "Config:"
    echo ""
    cat ${GITLAB_RUNNER_DATA_DIR}/config.toml
  fi
}

# allow arguments to be passed to gitlab-runner
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == gitlab-runner || ${1} == $(which gitlab-runner) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch gitlab-runner
if [[ -z ${1} ]]; then
  create_data_dir
  update_ca_certificates
  generate_ssh_deploy_keys
  grant_access_to_docker_socket
  configure_ci_runner
  configure_docker_credentials

  start-stop-daemon --start \
    --user ${GITLAB_RUNNER_USER} \
    --group ${GITLAB_RUNNER_USER} \
    --exec $(which gitlab-runner) -- run \
      --working-directory ${GITLAB_RUNNER_DATA_DIR} \
      --config ${GITLAB_RUNNER_DATA_DIR}/config.toml ${EXTRA_ARGS}
      
  echo "Stopping runner"
  if [[ "${RUNNER_AUTOUNREGISTER}" == "true" ]];then
    echo "Unregistering runner from ${CI_SERVER_URL}"
    sudo -HEu ${GITLAB_RUNNER_USER} \
    gitlab-runner unregister --url ${CI_SERVER_URL} --token $(grep token ${GITLAB_RUNNER_DATA_DIR}/config.toml | awk '{print $3}' | tr -d '"')
  fi
else
  exec "$@"
fi

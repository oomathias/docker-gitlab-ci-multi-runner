# Changelog

**11.6.0**
- gitlab-runner: upgrade to 11.6.0

**11.3.1**
- gitlab-runner: upgrade to 11.3.1
- dumb-init: upgrade to 1.2.2
- glibc: upgrade to 2.28-r0

**10.1.0**
- gitlab-ci-multi-runner -> gitlab-runner
- gitlab-runner: upgrade to 10.1.0

## Available variables

You can customise the runner with the following env variables:
- CA_CERTIFICATES_PATH: the path to your certificate
- RUNNER_CONCURRENT: the number of concurrent job the runner can start
- CI_SERVER_URL: your server URL (suffixed by /ci)
- RUNNER_TOKEN: the runner token corresponding to your project
- RUNNER_EXECUTOR: the executor to start
- RUNNER_DESCRIPTION: the description of the runner, displayed in gitlab ui
- RUNNER_DOCKER_IMAGE: the default image to run when starting a build
- RUNNER_DOCKER_MODE: the docker mode to use, socket or dind
- RUNNER_DOCKER_PRIVATE_REGISTRY_URL: url of private registry the runner should access
- RUNNER_DOCKER_PRIVATE_REGISTRY_TOKEN: token of private registry the runner should access
- RUNNER_DOCKER_ADDITIONAL_VOLUME: additionals volumes to share between host and jobs
- RUNNER_OUTPUT_LIMIT: output limit in KB that a build can produce
- RUNNER_AUTOUNREGISTER: auto unregister the runner when the container stops

**9.5.0**
- gitlab-ci-multi-runner: upgrade to 9.5.0

**9.2.0**
- gitlab-ci-multi-runner: upgrade to 9.2.0

**1.11.4**
- gitlab-ci-multi-runner: upgrade to 1.11.4
- rancher-compose: upgrade to 0.12.5

**1.10.0**
- gitlab-ci-multi-runner: upgrade to 1.10.0

**1.9.1**
- gitlab-ci-multi-runner: upgrade to 1.9.1
- rancher-compose: upgrade to 0.12.1

**1.8.1**
- gitlab-ci-multi-runner: upgrade to 1.8.1
- rancher-compose: upgrade to 0.12.0

**1.8.0**
- gitlab-ci-multi-runner: upgrade to 1.8.0
- dumb-init: upgrade to 1.2.0

**1.6.0**
- gitlab-ci-multi-runner: upgrade to 1.6.0

**1.5.3**
- gitlab-ci-multi-runner: upgrade to 1.5.3
- initial creation, adapted from https://github.com/sameersbn/docker-gitlab-ci-multi-runner

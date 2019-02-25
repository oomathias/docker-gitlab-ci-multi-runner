[![Docker Repository on Quay](https://quay.io/repository/oomathias/docker-gitlab-ci-multi-runner/status 'Docker Repository on Quay')](https://quay.io/repository/oomathias/docker-gitlab-ci-multi-runner)

# oomathias/docker-gitlab-runner:latest

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/oomathias/docker-gitlab-runner) and is the recommended method of installation.

> **Note**: Builds are also available on [Quay.io](https://quay.io/repository/oomathias/docker-gitlab-runner)

```bash
docker pull oomathias/docker-gitlab-runner:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t oomathias/docker-gitlab-runner oomathias/docker-gitlab-runner
```

## Quickstart

Before a runner can process your CI jobs, it needs to be authorized to access the the GitLab CI server. The `CI_SERVER_URL`, `RUNNER_TOKEN`, `RUNNER_DESCRIPTION` and `RUNNER_EXECUTOR` environment variables are used to register the runner on GitLab CI.

You can use any ENV variable supported by the gitlab ci runner.

```bash
docker run --name gitlab-ci-multi-runner -d --restart=always \
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  --env='CI_SERVER_URL=http://git.example.com/ci' --env='RUNNER_TOKEN=xxxxxxxxx' \
  --env='RUNNER_DESCRIPTION=myrunner' --env='RUNNER_EXECUTOR=shell' \
  oomathias/docker-gitlab-runner:latest
```

_Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)_

Update the values of `CI_SERVER_URL`, `RUNNER_TOKEN` and `RUNNER_DESCRIPTION` in the above command. If these enviroment variables are not specified, you will be prompted to enter these details interactively on first run.

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
- ENV_VARS: expose environment variables inside the docker image (RUNNER_DOCKER_IMAGE)
- EXTRA_ARGS: extra arguments for gitlab-runner --run
- Any others env supported by gitlab-runner

## Using docker executor

You can use the docker executor by using `RUNNER_EXECUTOR=docker`. You can provide a docker image to use in `RUNNER_DOCKER_IMAGE` (docker:latest by default)

If `RUNNER_DOCKER_MODE` is set to `socket`, the docker socket is shared between the runner and the build container. If it is not, you must use docker in docker service in your .gitlabci.yml definitions.

Start the docker runner in socket mode :

```bash
docker run --name gitlab-ci-multi-runner -d --restart=always \
  --volume /var/run/docker.sock:/var/run/docker.sock
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  --env='CI_SERVER_URL=http://git.example.com/ci' --env='RUNNER_TOKEN=xxxxxxxxx' \
  --env='RUNNER_DESCRIPTION=myrunner' --env='RUNNER_EXECUTOR=docker' \
  --env='RUNNER_DOCKER_IMAGE=docker:latest' --env='RUNNER_DOCKER_MODE=socket'
  oomathias/docker-gitlab-runner:latest
```

Start the docker runner in dind mode :

```bash
docker run --name gitlab-ci-multi-runner -d --restart=always \
  --volume /var/run/docker.sock:/var/run/docker.sock
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  --env='CI_SERVER_URL=http://git.example.com/ci' --env='RUNNER_TOKEN=xxxxxxxxx' \
  --env='RUNNER_DESCRIPTION=myrunner' --env='RUNNER_EXECUTOR=docker' \
  --env='RUNNER_DOCKER_IMAGE=docker:latest' --env='RUNNER_DOCKER_MODE=dind'
  oomathias/docker-gitlab-runner:latest
```

If you want to share volumes between your containers and the runner in socket mode, use the `RUNNER_DOCKER_ADDITIONAL_VOLUME` variable to share `/builds:/builds`.

You can increase the log maximum size by setting the RUNNER_OUTPUT_LIMIT variable (in kb)

See https://docs.gitlab.com/ce/ci/docker/using_docker_build.html for more info.

## Concurrent jobs

You an setup your runner to start multiple job in parallel by setting the environment variable `RUNNER_CONCURRENT` to the number of jobs you want to run concurrently.

## Command-line arguments

You can customize the launch command by specifying arguments to `gitlab-ci-multi-runner` on the `docker run` command. For example the following command prints the help menu of `gitlab-ci-multi-runner` command:

```bash
docker run --name gitlab-ci-multi-runner -it --rm \
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  oomathias/docker-gitlab-runner:latest --help
```

## Persistence

For the image to preserve its state across container shutdown and startup you should mount a volume at `/etc/gitlab-runner`.

## Deploy Keys

At first run the image automatically generates SSH deploy keys which are installed at `/home/gitlab-runner/.ssh` of the persistent data store. You can replace these keys with your own if you wish to do so.

You can use these keys to allow the runner to gain access to your private git repositories over the SSH protocol.

> **NOTE**
>
> - The deploy keys are generated without a passphrase.
> - If your CI jobs clone repositories over SSH, you will need to build the ssh known hosts file which can be done in the build steps using, for example, `ssh-keyscan github.com | sort -u - ~/.ssh/known_hosts -o ~/.ssh/known_hosts`.

## Trusting SSL Server Certificates

If your GitLab server is using self-signed SSL certificates then you should make sure the GitLab server's SSL certificate is trusted on the runner for the git clone operations to work.

The runner is configured to look for trusted SSL certificates at `/etc/gitlab-runner/certs/ca.crt`. This path can be changed using the `CA_CERTIFICATES_PATH` enviroment variable.

Create a file named `ca.crt` in a `certs` folder at the root of your persistent data volume. The `ca.crt` file should contain the root certificates of all the servers you want to trust.

With respect to GitLab, append the contents of the `gitlab.crt` file to `ca.crt`. For more information on the `gitlab.crt` file please refer the [README](https://github.com/sameersbn/docker-gitlab/blob/master/README.md#ssl) of the [docker-gitlab](https://github.com/sameersbn/docker-gitlab) container.

Similarly you should also trust the SSL certificate of the GitLab CI server by appending the contents of the `gitlab-ci.crt` file to `ca.crt`.

# Maintenance

## Upgrading

To upgrade to newer releases:

1. Download the updated Docker image:

```bash
docker pull oomathias/docker-gitlab-runner:latest
```

2. Stop the currently running image:

```bash
docker stop gitlab-ci-multi-runner
```

3. Remove the stopped container

```bash
docker rm -v gitlab-ci-multi-runner
```

4. Start the updated image

```bash
docker run -name gitlab-ci-multi-runner -d \
  [OPTIONS] \
  oomathias/docker-gitlab-runner:latest
```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it gitlab-ci-multi-runner bash
```

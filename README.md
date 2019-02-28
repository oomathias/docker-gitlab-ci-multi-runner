# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/oomathias/gitlab-runner) and is the recommended method of installation.

```bash
docker pull oomathias/gitlab-runner:latest
```

## Quickstart

Before a runner can process your CI jobs, it needs to be authorized to access the the GitLab CI server. The `CI_SERVER_URL`, `REGISTRATION_TOKEN`, `RUNNER_NAME` and `RUNNER_EXECUTOR` environment variables are used to register the runner on GitLab CI.

You can use any ENV variable supported by the official gitlab-runner.

```bash
docker run --name gitlab-runner -d --restart=always \
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  --env='CI_SERVER_URL=https://git.example.com' --env='REGISTRATION_TOKEN=xxxxxxxxx' \
  --env='RUNNER_NAME=myrunner' --env='RUNNER_EXECUTOR=shell' \
  oomathias/gitlab-runner:latest
```

_Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)_

Update the values of `CI_SERVER_URL`, `REGISTRATION_TOKEN` and `RUNNER_NAME` in the above command. If these environment variables are not specified, you will be prompted to enter these details interactively on first run.

## Available variables

Mandatory for autoregister:

- **CI_SERVER_URL**: Server URL
- **REGISTRATION_TOKEN**: Runner registration token

You can customise the runner with the following env variables:

- **RUNNER_AUTOUNREGISTER**: Auto unregister the runner when the container stops (default: `true`)
- **RUNNER_CHECK_INTERVAL**: Defines the interval length, in seconds, between new jobs check. (default: `3`)
- **RUNNER_CONCURRENCY**: Set the number of concurrent job the runner can start (default: `1`)
- **RUNNER_ENV**: Custom environment variables injected to build environment. **With support for multi vars** (example: `-e RUNNER_ENV="TEST=4 HELLO=WORLD"`)
- **RUNNER_EXECUTOR**: Select executor, eg. `shell`, `docker`, etc. (default: `docker`)
- **RUNNER_NAME**: Runner name, show as descripton in the UI (default: `runner`)
- **RUNNER_SESSION_TIMEOUT**: How long in seconds the session can stay active after the job completes (which will block the job from finishing), defaults to 1800 (30 minutes).
- **DOCKER_MODE**: The docker mode to use, `socket` or `dind` or `none`. `socket` will automount `/var/run/docker.sock`, `dind` do nothing special yet (default: `dind`)
- **CA_CERTIFICATES_PATH**: Set the path to your certificate

Any others env supported by gitlab/gitlab-runner:

- **CONFIG_FILE** Config file
- **RUNNER_TAG_LIST** Tag list
- **REGISTER_NON_INTERACTIVE** Run registration unattended
- **REGISTER_LEAVE_RUNNER** Don't remove runner if registration fails
- **REGISTER_RUN_UNTAGGED** Register to run untagged builds; defaults to 'true' when 'tag-list' is empty
- **REGISTER_LOCKED** Lock Runner for current project, defaults to 'true'
- **REGISTER_MAXIMUM_TIMEOUT** What is the maximum timeout (in seconds) that will be set for job when using this Runner
- **REGISTER_PAUSED** Set Runner to be paused, defaults to 'false'
- **RUNNER_LIMIT** Maximum number of builds processed by this runner
- **RUNNER_OUTPUT_LIMIT** Maximum build trace size in kilobytes
- **RUNNER_REQUEST_CONCURRENCY** Maximum concurrency for job requests
- **CI_SERVER_URL** Runner URL
- **CI_SERVER_TOKEN** Runner token
- **CI_SERVER_TLS_CA_FILE** File containing the certificates to verify the peer when using HTTPS
- **CI_SERVER_TLS_CERT_FILE** File containing certificate for TLS client auth when using HTTPS
- **CI_SERVER_TLS_KEY_FILE** File containing private key for TLS client auth when using HTTPS
- **RUNNER_BUILDS_DIR** Directory where builds are stored
- **RUNNER_CACHE_DIR** Directory where build cache is stored
- **CLONE_URL** Overwrite the default URL used to clone or fetch the git ref
- **RUNNER_PRE_CLONE_SCRIPT** Runner-specific command script executed before code is pulled
- **RUNNER_PRE_BUILD_SCRIPT** Runner-specific command script executed after code is pulled, just before build executes
- **RUNNER_POST_BUILD_SCRIPT** Runner-specific command script executed after code is pulled and just after build executes
- **RUNNER_SHELL** Select bash, cmd or powershell
- **SSH_USER** User name
- **SSH_PASSWORD** User password
- **SSH_HOST** Remote host
- **SSH_PORT** Remote host port
- **SSH_IDENTITY_FILE** Identity file to be used
- **DOCKER_HOST** Docker daemon address
- **DOCKER_CERT_PATH** Certificate path
- **DOCKER_TLS_VERIFY** Use TLS and verify the remote
- **DOCKER_HOSTNAME** Custom container hostname
- **DOCKER_IMAGE** Docker image to be used
- **DOCKER_RUNTIME** Docker runtime to be used
- **DOCKER_MEMORY** Memory limit (format: <number>[<unit>]). Unit can be one of b, k, m, or g. Minimum is 4M.
- **DOCKER_MEMORY_SWAP** Total memory limit (memory + swap, format: <number>[<unit>]). Unit can be one of b, k, m, or g.
- **DOCKER_MEMORY_RESERVATION** Memory soft limit (format: <number>[<unit>]). Unit can be one of b, k, m, or g.
- **DOCKER_CPUSET_CPUS** String value containing the cgroups CpusetCpus to use
- **DOCKER_CPUS** Number of CPUs
- **DOCKER_DNS** A list of DNS servers for the container to use
- **DOCKER_DNS_SEARCH** A list of DNS search domains
- **DOCKER_PRIVILEGED** Give extended privileges to container
- **DOCKER_DISABLE_ENTRYPOINT_OVERWRITE** Disable the possibility for a container to overwrite the default image entrypoint
- **DOCKER_USERNS_MODE** User namespace to use
- **DOCKER_CAP_ADD** Add Linux capabilities
- **DOCKER_CAP_DROP** Drop Linux capabilities
- **DOCKER_OOM_KILL_DISABLE** Do not kill processes in a container if an out-of-memory (OOM) error occurs
- **DOCKER_SECURITY_OPT** Security Options
- **DOCKER_DEVICES** Add a host device to the container
- **DOCKER_DISABLE_CACHE** Disable all container caching
- **DOCKER_VOLUMES** Bind mount a volumes
- **DOCKER_VOLUME_DRIVER** Volume driver to be used
- **DOCKER_CACHE_DIR** Directory where to store caches
- **DOCKER_EXTRA_HOSTS** Add a custom host-to-IP mapping
- **DOCKER_VOLUMES_FROM** A list of volumes to inherit from another container
- **DOCKER_NETWORK_MODE** Add container to a custom network
- **DOCKER_LINKS** Add link to another container
- **DOCKER_SERVICES** Add service that is started with container
- **DOCKER_WAIT_FOR_SERVICES_TIMEOUT** How long to wait for service startup
- **DOCKER_ALLOWED_IMAGES** Whitelist allowed images
- **DOCKER_ALLOWED_SERVICES** Whitelist allowed services
- **DOCKER_PULL_POLICY** Image pull policy: never, if-not-present, always
- **DOCKER_SHM_SIZE** Shared memory size for docker images (in bytes)
- **DOCKER_TMPFS** A toml table/json object with the format key=values. When set this will mount the specified path in the key as a tmpfs volume in the - main container, using the options specified as key. For the supported options, see the documentation for the unix 'mount' command
- **DOCKER_SERVICES_TMPFS** A toml table/json object with the format key=values. When set this will mount the specified path in the key as a tmpfs volume in all the service containers, using the options specified as key. For the supported options, see the documentation for the unix 'mount' command
- **DOCKER_SYSCTLS** Sysctl options, a toml table/json object of key=value. Value is expected to be a string.
- **DOCKER_HELPER_IMAGE** [ADVANCED] Override the default helper image used to clone repos and upload artifacts
- **PARALLELS_BASE_NAME** VM name to be used
- **PARALLELS_TEMPLATE_NAME** VM template to be created
- **PARALLELS_DISABLE_SNAPSHOTS** Disable snapshoting to speedup VM creation
- **VIRTUALBOX_BASE_NAME** VM name to be used
- **VIRTUALBOX_BASE_SNAPSHOT** Name or UUID of a specific VM snapshot to clone
- **VIRTUALBOX_DISABLE_SNAPSHOTS** Disable snapshoting to speedup VM creation
- **CACHE_TYPE** Select caching method
- **CACHE_PATH** Name of the path to prepend to the cache URL
- **CACHE_SHARED** Enable cache sharing between runners.
- **CACHE_S3_SERVER_ADDRESS** A host:port to the used S3-compatible server
- **CACHE_S3_ACCESS_KEY** S3 Access Key
- **CACHE_S3_SECRET_KEY** S3 Secret Key
- **CACHE_S3_BUCKET_NAME** Name of the bucket where cache will be stored
- **CACHE_S3_BUCKET_LOCATION** Name of S3 region
- **CACHE_S3_INSECURE** Use insecure mode (without https)
- **CACHE_GCS_ACCESS_ID** ID of GCP Service Account used to access the storage
- **CACHE_GCS_PRIVATE_KEY** Private key used to sign GCS requests
- **GOOGLE_APPLICATION_CREDENTIALS** File with GCP credentials, containing AccessID and PrivateKey
- **CACHE_GCS_BUCKET_NAME** Name of the bucket where cache will be stored
- **MACHINE_IDLE_COUNT** Maximum idle machines
- **MACHINE_IDLE_TIME** Minimum time after node can be destroyed
- **MACHINE_MAX_BUILDS** Maximum number of builds processed by machine
- **MACHINE_DRIVER** The driver to use when creating machine
- **MACHINE_NAME** The template for machine name (needs to include %s)
- **MACHINE_OPTIONS** Additional machine creation options
- **MACHINE_OFF_PEAK_PERIODS** Time periods when the scheduler is in the OffPeak mode
- **MACHINE_OFF_PEAK_TIMEZONE** Timezone for the OffPeak periods (defaults to Local)
- **MACHINE_OFF_PEAK_IDLE_COUNT** Maximum idle machines when the scheduler is in the OffPeak mode
- **MACHINE_OFF_PEAK_IDLE_TIME** Minimum time after machine can be destroyed when the scheduler is in the OffPeak mode
- **KUBERNETES_HOST** Optional Kubernetes master host URL (auto-discovery attempted if not specified)
- **KUBERNETES_CERT_FILE** Optional Kubernetes master auth certificate
- **KUBERNETES_KEY_FILE** Optional Kubernetes master auth private key
- **KUBERNETES_CA_FILE** Optional Kubernetes master auth ca certificate
- **KUBERNETES_BEARER_TOKEN_OVERWRITE_ALLOWED** token_overwrite_allowed Bool to authorize builds to specify their own bearer token for creation.
- **KUBERNETES_BEARER_TOKEN** Optional Kubernetes service account token used to start build pods.
- **KUBERNETES_IMAGE** Default docker image to use for builds when none is specified
- **KUBERNETES_NAMESPACE** Namespace to run Kubernetes jobs in
- **KUBERNETES_NAMESPACE_OVERWRITE_ALLOWED** Regex to validate 'KUBERNETES_NAMESPACE_OVERWRITE' value
- **KUBERNETES_PRIVILEGED** Run all containers with the privileged flag enabled
- **KUBERNETES_CPU_LIMIT** The CPU allocation given to build containers
- **KUBERNETES_MEMORY_LIMIT** The amount of memory allocated to build containers
- **KUBERNETES_SERVICE_CPU_LIMIT** The CPU allocation given to build service containers
- **KUBERNETES_SERVICE_MEMORY_LIMIT** The amount of memory allocated to build service containers
- **KUBERNETES_HELPER_CPU_LIMIT** The CPU allocation given to build helper containers
- **KUBERNETES_HELPER_MEMORY_LIMIT** The amount of memory allocated to build helper containers
- **KUBERNETES_CPU_REQUEST** The CPU allocation requested for build containers
- **KUBERNETES_MEMORY_REQUEST** The amount of memory requested from build containers
- **KUBERNETES_SERVICE_CPU_REQUEST** The CPU allocation requested for build service containers
- **KUBERNETES_SERVICE_MEMORY_REQUEST** The amount of memory requested for build service containers
- **KUBERNETES_HELPER_CPU_REQUEST** The CPU allocation requested for build helper containers
- **KUBERNETES_HELPER_MEMORY_REQUEST** The amount of memory requested for build helper containers
- **KUBERNETES_PULL_POLICY** Policy for if/when to pull a container image (never, if-not-present, always). The cluster default will be used if not set
- **KUBERNETES_NODE_SELECTOR** A toml table/json object of key=value. Value is expected to be a string. When set this will create pods on k8s nodes that match all the key=value pairs.
- **KUBERNETES_NODE_TOLERATIONS** A toml table/json object of key=value:effect. Value and effect are expected to be strings. When set, pods will tolerate the given taints. Only one toleration is supported through environment variable configuration.
- **KUBERNETES_IMAGE_PULL_SECRETS** A list of image pull secrets that are used for pulling docker image
- **KUBERNETES_HELPER_IMAGE** [ADVANCED] Override the default helper image used to clone repos and upload artifacts
- **KUBERNETES_TERMINATIONGRACEPERIODSECONDS** Duration after the processes running in the pod are sent a termination signal and the time when the processes are forcibly halted with a kill signal.
- **KUBERNETES_POLL_INTERVAL** How frequently, in seconds, the runner will poll the Kubernetes pod it has just created to check its status
- **KUBERNETES_POLL_TIMEOUT** The total amount of time, in seconds, that needs to pass before the runner will timeout attempting to connect to the pod it - has just created (useful for queueing more builds that the cluster can handle at a time)
- **KUBERNETES_SERVICE_ACCOUNT** Executor pods will use this Service Account to talk to kubernetes API
- **KUBERNETES_SERVICE_ACCOUNT_OVERWRITE_ALLOWED** Regex to validate 'KUBERNETES_SERVICE_ACCOUNT' value

## Using docker executor

You can use the docker executor by using `RUNNER_EXECUTOR=docker`. You can provide a docker image to use in `DOCKER_IMAGE` (docker:latest by default)

If `DOCKER_MODE` is set to `socket`, the docker socket is shared between the runner and the build container. If it is not, you must use docker in docker service in your .gitlabci.yml definitions.

Start the docker runner in socket mode :

```bash
docker run --name gitlab-runner -d --restart=always \
  --volume /var/run/docker.sock:/var/run/docker.sock
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  --env='CI_SERVER_URL=https://git.example.com' --env='REGISTRATION_TOKEN=xxxxxxxxx' \
  --env='RUNNER_NAME=myrunner' --env='RUNNER_EXECUTOR=docker' \
  --env='DOCKER_IMAGE=docker:latest' --env='DOCKER_MODE=socket'
  oomathias/gitlab-runner:latest
```

Start the docker runner in dind mode :

```bash
docker run --name gitlab-runner -d --restart=always \
  --volume /var/run/docker.sock:/var/run/docker.sock
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  --env='CI_SERVER_URL=https://git.example.com' --env='REGISTRATION_TOKEN=xxxxxxxxx' \
  --env='RUNNER_NAME=myrunner' --env='RUNNER_EXECUTOR=docker' \
  --env='DOCKER_IMAGE=docker:latest' --env='DOCKER_MODE=dind'
  oomathias/gitlab-runner:latest
```

If you want to share volumes between your containers and the runner in socket mode, use the `DOCKER_VOLUMES` variable to share `/builds:/builds`.

You can increase the log maximum size by setting the RUNNER_OUTPUT_LIMIT variable (in kb)

See https://docs.gitlab.com/ce/docker/using_docker_build.html for more info.

## Concurrent jobs

You an setup your runner to start multiple job in parallel by setting the environment variable `RUNNER_CONCURRENCY` to the number of jobs you want to run concurrently.

## Command-line arguments

You can customize the launch command by specifying arguments to `gitlab-runner` on the `docker run` command. For example the following command prints the help menu of `gitlab-runner` command:

```bash
docker run --name gitlab-runner -it --rm \
  --volume /srv/docker/gitlab-runner:/etc/gitlab-runner \
  oomathias/gitlab-runner:latest --help
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

The runner is configured to look for trusted SSL certificates at `/etc/gitlab-runner/certs/ca.crt`. This path can be changed using the `CA_CERTIFICATES_PATH` environment variable.

Create a file named `ca.crt` in a `certs` folder at the root of your persistent data volume. The `ca.crt` file should contain the root certificates of all the servers you want to trust.

With respect to GitLab, append the contents of the `gitlab.crt` file to `ca.crt`. For more information on the `gitlab.crt` file please refer the [README](https://github.com/sameersbn/docker-gitlab/blob/master/README.md#ssl) of the [docker-gitlab](https://github.com/sameersbn/docker-gitlab) container.

Similarly you should also trust the SSL certificate of the GitLab CI server by appending the contents of the `gitlab-ci.crt` file to `ca.crt`.

# Maintenance

## Upgrading

To upgrade to newer releases:

1. Download the updated Docker image:

```bash
docker pull oomathias/gitlab-runner:latest
```

2. Stop the currently running image:

```bash
docker stop gitlab-runner
```

3. Remove the stopped container

```bash
docker rm -v gitlab-runner
```

4. Start the updated image

```bash
docker run -name gitlab-runner -d \
  [OPTIONS] \
  oomathias/gitlab-runner:latest
```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it gitlab-runner bash
```

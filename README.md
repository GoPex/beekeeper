Beekeeper
=========

Getting started
---------------

### Installation

As Beekeeper is packaged in a Docker container, to install it, you must have docker installed and running ([install docker](https://docs.docker.com/installation/#installation)) and then run:

### Start Beekeeper

You can start Beekeeper without configuration with:

```shell
sudo docker run --name beekeeper -e ${ACCESS_ID}_API_KEY=API_KEY_FOR_${ACCESS_ID} -d -p 3000:3000 -v /var/run:/var/run docker-registry.gopex.be:5000/gopex/beekeeper:0.4.0
```

### Parameters

General parameters are handled through Docker:

- __Name__ `--name beekeeper` - Name given to the container running Beekeeper, optional but make life easier.
- __Api key__ `-e ${ACCESS_ID}_API_KEY` - As from version 0.2.0, you must use the authentication mechanism. To do so, give an environment variable with the secret key to use for a given access id. For example, if my access id is 1337, the name would be `1337_API_KEY`.
- __Daemon mode__ `-d` - Make the container launched to run as a daemon. Remove the `-d` flag to see Beekeeper's logs as STDOUT or use the `docker logs -f` command.
- __Port__ `-p 3000:3000` - the port to open, Beekeeper listen to port 3000 by default.
- __Docker socket__ `-v /var/run:/var/run` - will mount your local daemon host socket to beekeeper container.

### Variables

Beekeeper specific configuration are handled through Docker via environment variables:

- __Docker host__ `-e DOCKER_HOST_URL=tcp://DOCKER_HOST_IP:DOCKER_HOST_PORT` - Will connect Beekeeper to the given docker host url via TCP. This will override any Docker socket usage, meaning mounting a Docker socket is not needed anymore. You'll need to ([bind docker daemon to a network interface](https://docs.docker.com/engine/quickstart/#bind-docker-to-another-host-port-or-a-unix-socket)) to use this feature. Default is to use docker unix socket.
- __Docker host public__ `-e DOCKER_HOST_PUBLIC_URL=DOCKER_HOST_PUBLIC_IP` - Will be used by Beekeeper when replying to from the complete public url of created bees. Default is `DOCKER_HOST_URL` or `127.0.0.1` if using Docker on a unix socket.
- __Beekeeper bind__ `-e BIND=unix:///var/run/beekeeper_puma.sock` - Will configure Beekeeper to listen on a specific unix socket. Use you also use it to configure Beekeeper to listen on a specific network interface/port but be careful as the default Beekeeper image only expose port 3000. Default to `tcp://0.0.0.0:3000`
- __Beekeeper concurrency__ `-e CONCURRENCY=4` - Will set the Beekeeper concurrency level to 4. Default is 2.
- __Beekeeper maximum threads__ `-e MAX_THREADS=20` - Will set Beekeeper maximum threads per concurrency to 20. Default is 10.
- __Rails environment__ `-e RAILS_ENV=production` - Will set rails environment to production. Default is development.
- __Beekeeper registry password__ `BEEKEEPER_REGISTRY_PASSWORD=PASSWORD` - Will be used by Beekeeper to handle registry when specified. Beekeeper will always use credentials to call private registry for the moment.

### Resource name

As Beekeeper is intended to only manage its own set of Docker container, we will call them `bee` from now. To achieve that, Beekeeper will label all container with a custom label and filter container that way.

API documentation
-----------------

### Informations about Beekeeper

#### Ping beekeeper 
`GET    /info/ping(.json)`

#### Get beekeeper status
`GET    /info/status(.json)`

#### Get beekeeper version
`GET    /info/version(.json)`

#### Get Docker daemon version of the Docker host used by Beekeeper
`GET    /info/docker_version(.json)`

#### Get Docker daemon information of the Docker host used by Beekeeper
`GET    /info/docker(.json)`

### Manage bees

#### Get a bee
`GET    /bees/:id(.json)`

#### Get all the bees
`GET    /bees(.json)`

#### Create a bee
`POST   /bees(.json)`

##### JSON parameters
- __container__ `Hash` :
    - __image__ `String` - Image to use, must be complete if you want to use a private registry as Docker hub is used by default.
    - __registry__ `String` - If your image is not hosted publicly on the docker hub, you must specify the registry using this parameter. Credentials used to connect to the hub will be beekeeper:$BEEKEEPER_REGISTRY_PASSWORD.
    - __entrypoint__ `String (optional)` - Entry point to use when starting the container. This will overwrite any `ENTRYPOINT` defined in the image used.
    - __parameters__ `[String] (optional)` - Parameters used by the entry point when starting the container. This will overwrite any `CMD` defined in the image used.
    - __ports__ `[String] (optional)` - Ports to expose when starting the container. This port must be exposed in the image as Beekeeper will not expose port dynamically.

#### Destroy a bee
`DELETE /bees/:id(.json)`

Usage examples
--------------

### See [Beekeeper-api](https://bitbucket.org/gopex/beekeeper-api) !

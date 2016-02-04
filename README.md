Beekeeper
=========

Getting started
---------------

### Installation

As Beekeeper is packaged in a Docker container, to install it, you must have docker installed and running ([install docker](https://docs.docker.com/installation/#installation)) and then run:

### Start Beekeeper

You can start Beekeeper without configuration with:

```shell
sudo docker run --name beekeeper -d -p 3000:3000 -v /var/run:/var/run docker-registry.gopex.be:5000/gopex/beekeeper:0.1.0
```

### Parameters

General parameters are handled through Docker:

- __Name__ `--name beekeeper`: Name given to the container running Beekeeper, optional but make life easier.
- __Daemon mode__ `-d`: Make the container launched to run as a daemon. Remove the `-d` flag to see Beekeeper's logs as STDOUT or use the `docker logs -f` command.
- __Port__ `-p 3000:3000`: the port to open, Beekeeper listen to port 3000 by default.
- __Docker socket__ `-v /var/run:/var/run`: will mount your local daemon host socket to beekeeper container.

### Variables

Beekeeper specific configuration are handled through Docker via environment variables:

- __Docker host__ `-e DOCKER_HOST_URL=tcp://DOCKER_HOST_IP:DOCKER_HOST_PORT`: Will connect Beekeeper to the given docker host url via TCP. This will override any Docker socket usage, meaning mounting a Docker socket is not needed anymore. You'll need to ([bind docker daemon to a network interface](https://docs.docker.com/installation/#installation)) to use this feature. Default is use docker unix socket.
- __Beekeeper bind__ `-e BIND=unix:///var/run/beekeeper_puma.sock`: Will configure Beekeeper to listen on a specific unix socket. Use you also use it to configure Beekeeper to listen on a specific network interface/port but be careful as the default Beekeeper image only expose port 3000. Default to `tcp://0.0.0.0:3000`
- __Beekeeper concurrency__ `-e CONCURRENCY=4` : Will set the Beekeeper concurrency level to 4. Default is 2.
- __Beeleeper maximum threads__ `-e MAX_THREADS=20` : Will set Beekeeper maximum threads per concurrency to 20. Default is 10.

### Resource name

As Beekeeper is intended to only manage its own set of Docker container, we will call them `bee` from now. To achieve that, Beekeeper will label all container with a custom label and filter container that way.

API documentation
-----------------

### Informations about Beekeeper

#### Get beekeeper version
`GET    /info/version(.json)`

#### Get Docker daemon version of the Docker host used by Beekeeper
`GET    /info/docker_version(.json)`

#### Get Docker daemon information of the Docker host used by Beekeeper
`GET    /info/docker(.json)`

### Manage bees

#### Get all the bees
`GET    /containers(.json)`

#### Create a bee
`POST   /containers(.json)`

##### JSON parameters
- __container__ `Hash`:
..- __image__ `String`: Image to use, must be complete if you want to use a private registry as Docker hub is used by default.
..- __entrypoint__ `String`(optional): Entry point to use when starting the container. This will overwrite any `ENTRYPOINT` defined in the image used.
..- __parameters__ `[String]`(optional): Parameters used by the entry point when starting the container. This will overwrite any `CMD` defined in the image used.
..- __ports__ `[String]`(optional): Port to expose when starting the container. This port must be exposed in the image as Beekeeper will not expose port dynamically.

#### Destroy a bee
`DELETE /containers/:id(.json)`

Usage examples
--------------

### Using curl

#### Create a basic bee

```shell
# Test beekeeper by creating a bee based upon the busybox
curl -H 'Content-Type: application/json' -X POST -d '{"container": {"image":"busybox", "entrypoint":"tail", "parameters": ["-f", "/dev/null"]}}' http://localhost:3000/containers
	=> {"id":"2220068471af577981b8712858199c1cec79a88336809e26ff996dbd56400c10","status":"running","address":{}}%
```

#### A bee with an exposed port

```shell
# For this one, as we want to expose a port, we need to build an image with a specific port exposed as Beekeeper will not use non-pre-exposed port while starting a container. You can use the one used for the tests:
git clone git@bitbucket.org:gopex/beekeeper.git && cd beekeeper
sudo docker build -t="docker-registry.gopex.be:5000/gopex/beekeeper_test_image:0.1.0" test/fixtures/files/

# Then tell beekeeper to launch a container using the image that we have just created :
curl -H 'Content-Type: application/json' -X POST -d '{"container": {"image":"docker-registry.gopex.be:5000/gopex/beekeeper_test_image:0.1.0", "entrypoint":"tail", "parameters": ["-f", "/dev/null"], "ports": ["3000/tcp"]}}' http://localhost:3000/containers
	=> {"id":"18f61aa14f5513664b9685ca5c6b8454b6cd6f11e55c260c33ae3dfd4d374802","status":"running","address":{"3000/tcp":[{"HostIp":"0.0.0.0","HostPort":"32800"}]}}
```

#### Get all the bees

```shell
curl -H 'Content-Type: application/json' -X GET http://localhost:3000/containers/
    => {"2220068471af577981b8712858199c1cec79a88336809e26ff996dbd56400c10":{"status":"running","address":{}},
        "18f61aa14f5513664b9685ca5c6b8454b6cd6f11e55c260c33ae3dfd4d374802":{"status":"running","address":{"3000/tcp":[{"HostIp":"0.0.0.0","HostPort":"32800"}]}}}
```

#### Destroy previously created bees

```shell
curl -H 'Content-Type: application/json' -X DELETE http://localhost:3000/containers/2220068471af577981b8712858199c1cec79a88336809e26ff996dbd56400c10
    => {"id":"2220068471af577981b8712858199c1cec79a88336809e26ff996dbd56400c10","status":"deleted"}

curl -H 'Content-Type: application/json' -X DELETE http://localhost:3000/containers/18f61aa14f5513664b9685ca5c6b8454b6cd6f11e55c260c33ae3dfd4d374802
    => {"id":"18f61aa14f5513664b9685ca5c6b8454b6cd6f11e55c260c33ae3dfd4d374802","status":"deleted"}
```

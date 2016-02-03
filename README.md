Beekeeper
=========

Getting started
---------------

### Installation

As Beekeeper is packaged in a Docker container, to install it, you must have docker installed and running ([install docker](https://docs.docker.com/installation/#installation)). and then run:

### Start Beekeeper

You can start Beekeeper without configuration with:

```shell
sudo docker run --name beekeeper -d -p 3000:3000 -v /var/run:/var/run docker-registry.gopex.be:5000/gopex/beekeeper:0.1.0
```

### Parameters

Parameters are handled through Docker :

- __Name__ `--name beekeeper`: Name given to the container running Beekeeper, optional but make life easier.
- __Daemon mode__ `-d`: Make the container launched to run as a daemon. Remove the `-d` flag to see Beekeeper's logs as STDOUT or use the `docker logs -f` command.
- __Port__ `-p 3000:3000`: the port to open, Beekeeper listen to port 3000 by default.
- __Docker host__ or __Docker socket__ `-v /var/run:/var/run`: will mount your local daemon host socket to beekeeper container. You can also use `-e DOCKER_HOST_URL=tcp://172.17.0.1:2375` (with your docker's host IP/PORT combination) instead to connect Beekeeper with a remote docker host.

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

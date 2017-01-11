#!/bin/sh

# 1 username
# 2 password
# 3 image name
# 4 local image tag
# 5 docker hub tag


DOCKER_BIN=$(which docker)

$DOCKER_BIN login -u $1 -p $2 && \
$DOCKER_BIN tag $1/$3:$4 $1/$3:$5 && \
$DOCKER_BIN push $1/$3:$5 && \
$DOCKER_BIN logout

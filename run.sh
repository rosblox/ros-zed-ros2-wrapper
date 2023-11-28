#!/bin/bash

REPOSITORY_NAME="$(basename "$(dirname -- "$( readlink -f -- "$0"; )")")"

docker run -it --rm \
--network=host \
--ipc=host \
--pid=host \
--env UID=$(id -u) \
--env GID=$(id -g) \
--runtime=nvidia \
--privileged \
-v /dev:/dev \
ghcr.io/rosblox/${REPOSITORY_NAME}:humble

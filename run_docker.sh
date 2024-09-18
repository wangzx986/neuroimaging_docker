#!/bin/bash


# Always pull the latest image from Docker Hub, regardless of what's locally stored
echo "Checking for updates to the Docker image..."
docker pull wangzx94/neuroimaging_py311_update:latest

docker run --rm \
    -v /PATH/TO/SCRIPT:/scripts \
    -v /PATH/TO/DATAÍ:/data \
    -e USERNAME=USERNAME \
    --user $(id -u):$(id -g) \
    wangzx94/neuroimaging_py311_update:latest /bin/bash -c "/scripts/YOURSCRIPT.sh"


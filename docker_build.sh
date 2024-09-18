#!/bin/bash

docker image build \
    --build-arg USERNAME=${USER} \
    --build-arg USER_ID=$(id -u ${USER}) \
    --build-arg GROUP_ID=$(id -g ${USER}) \
    -t wangzx94/neuroimaging_py311_update:latest \
    -f neuroimaging_py311_update.Dockerfile .

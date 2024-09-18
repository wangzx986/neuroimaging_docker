#!/bin/bash

docker image build \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    -t wangzx94/neuroimaging_py311_update:latest \
    -f neuroimaging_py311_update.Dockerfile .

docker image build --build-arg USERNAME=zewang --build-arg USER_ID=$(id -u zewang) --build-arg GROUP_ID=$(id -g zewang) -t wangzx94/neuroimaging_py311_update:latest -f neuroimaging_py311_update.Dockerfile .
#!/bin/bash


# Always pull the latest image from Docker Hub, regardless of what's locally stored
echo "Checking for updates to the Docker image..."
docker pull wangzx94/neuroimaging_py311_update:latest

SUBJECT_PATH=$1

docker run --rm \
    -v /synapse_data/Zexi/CHDI/Scripts/Tractography_MRtrix:/scripts \
    -v /raid/jingwenyao/CHDI:/data \
    -e USERNAME=zewang \
    --user $(id -u zewang):$(id -g zewang) \
    wangzx94/neuroimaging_py311_update:latest /bin/bash -c "/scripts/create_cortex_ROI_mask_condor.sh $SUBJECT_PATH"


#!/usr/bin/env bash

# set -x

DOCKER_BUILDKIT=1; 
LOCAL_REGISTRY="localhost:5000"
NAME=$2
VERSION=$3
PLATFORMS=$4

declare -A TARGET
TARGET[cache]="";
TARGET[local]="${LOCAL_REGISTRY}/";
TARGET[github]="ghcr.io/configuredthings/"

## Validate args
if [[ $# -lt 2 ]]; then
    echo "Missing Paramater: $0 [local] name [platform,platform]"
    exit 1;
fi

PUSH=""
## Validate target
if [[ -z ${TARGET[$1]}+_ ]]; then
    echo "Invalid target: ${1}";
    exit 1;
elif [[ -z ${TARGET[$1]} ]]; then
    # Load to local image cache
    PUSH="--load"
else
    # Push to registry
    echo "Target is $1 : ${TARGET[$1]}"
    PUSH="--push=true"
fi

ssh-add;

PLATFORM_OPTS=""
if [[ ! -z ${PLATFORMS} ]]; then
    PLATFORM_OPTS="--platform ${PLATFORMS}"
fi

# Build the images
for f in images/* ; do
    SERVICE=${f##images/}

    set -x
    if [[ -f ${f}/Dockerfile ]]; then
        docker buildx build \
            --file ${f}/Dockerfile \
            --network=host \
            --build-arg LOCAL_REGISTRY=${LOCAL_REGISTRY} \
            ${PLATFORM_OPTS} \
            --secret id=npmrc,src=$HOME/.npmrc \
            --ssh default \
            -t ${TARGET[$1]}${NAME}_${SERVICE}:${VERSION} \
            ${PUSH} \
            .
    fi
    
done

#!/bin/bash

set -x
set -e

# generate unique docker containers name used to copy files from this containers.
DEV_CONTAINER_NAME=$(uuidgen)
ARTIFACT_CONTAINER_NAME=$(uuidgen)
TEMP_DOCKER_TAG=$(uuidgen)

rm -rf dockerconfig 2>/dev/null || true
# create docker config file
mkdir dockerconfig
cat > dockerconfig/config.json <<EOL
{
    "auths": {
        "https://artifactory.allegrogroup.com": {
            "auth": "$bamboo_artifactory_auth_password",
            "email": "$bamboo_artifactory_email"
        }
    }
}
EOL

# generate app version from git tags

# fetch cache
docker --config=dockerconfig pull \
    artifactory.allegrogroup.com/pl.allegro.tech.sdk/swiftbox-dev:latest || true


# build dev image
docker --config=dockerconfig build \
    -t artifactory.allegrogroup.com/pl.allegro.tech.sdk/swiftbox-dev:$TEMP_DOCKER_TAG \
    -f docker/Dockerfile-dev .

# run tests from runtime image
docker run --name $DEV_CONTAINER_NAME \
       artifactory.allegrogroup.com/pl.allegro.tech.sdk/swiftbox-dev:$TEMP_DOCKER_TAG \
       /opt/swiftbox/run_tests.sh


# create artifact file
docker run --name $ARTIFACT_CONTAINER_NAME \
    artifactory.allegrogroup.com/pl.allegro.tech.sdk/swiftbox-dev:$TEMP_DOCKER_TAG \
    /root/package_artifact.sh

# copy artifact file from docker container
mkdir -p artifact
docker cp $ARTIFACT_CONTAINER_NAME:/root/artifact/swiftbox.zip ./artifact/swiftbox.zip

src/get_version.sh > APP_VERSION


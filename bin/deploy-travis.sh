#!/bin/bash
set -e

DEIS_CONTROLLER=$1
DEIS_APP=$2
NEW_RELIC_APP_NAME=$3

docker login -e "$DOCKER_EMAIL" -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
docker push ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT}
docker tag -f ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT} ${DOCKER_REPOSITORY}:last_successful_build
docker push ${DOCKER_REPOSITORY}:last_successful_build

# Install deis client
curl -sSL http://deis.io/deis-cli/install.sh | sh
./deis login $DEIS_CONTROLLER --username $DEIS_USERNAME --password $DEIS_PASSWORD
./deis pull ${DOCKER_REPOSITORY}:${TRAVIS_COMMIT} -a $DEIS_APP
curl -H "x-api-key:$NEWRELIC_API_KEY" \
     -d "deployment[app_name]=$NEW_RELIC_APP_NAME" \
     -d "deployment[revision]=$TRAVIS_COMMIT" \
     -d "deployment[user]=Travis" \
     https://api.newrelic.com/deployments.xml

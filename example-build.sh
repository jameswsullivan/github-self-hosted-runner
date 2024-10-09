#!/bin/bash

ACTIONS_RUNNER_IMAGE_TAG='latest'
ACTIONS_RUNNER_IMAGE_FULL_TAG="<YOUR_IMAGE_REGISTRY_HOST_AND_PROJECTS>:${ACTIONS_RUNNER_IMAGE_TAG}"

echo "Building image ${ACTIONS_RUNNER_IMAGE_TAG} : "
echo

docker image build --tag ${ACTIONS_RUNNER_IMAGE_FULL_TAG} --progress plain --no-cache . 2>&1 | tee actions-runner-build.log

echo

echo "Finished building ${ACTIONS_RUNNER_IMAGE_FULL_TAG} : "
echo

docker image ls

echo
echo "Pushing image ${ACTIONS_RUNNER_IMAGE_FULL_TAG} : "

docker image push ${ACTIONS_RUNNER_IMAGE_FULL_TAG}

echo
echo "Done pushing ${ACTIONS_RUNNER_IMAGE_FULL_TAG} ."
echo

echo "Removing image: ${ACTIONS_RUNNER_IMAGE_FULL_TAG} ... "
echo

docker image rm ${ACTIONS_RUNNER_IMAGE_FULL_TAG}
docker system prune --force

echo
echo "Done removing image ${ACTIONS_RUNNER_IMAGE_FULL_TAG} ."
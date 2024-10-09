#!/bin/bash

echo "Adding \"runner\" user to \"/var/run/docker.sock\"\'s group : "
echo
echo 'Before changing:'
echo

sudo getent group docker

echo 'After changing: '
echo

DOCKER_SOCK_GID=$(stat -c "%g" /var/run/docker.sock)
sudo groupmod -g ${DOCKER_SOCK_GID} docker

sudo getent group docker

echo "Done adding \"runner\" to ${DOCKER_SOCK_GID} ."
echo

echo 'Adding "KubeConfig" from "actionrunner_sa" account : '
echo

mkdir -p $HOME/.kube
echo "${KUBECONFIG_CONTENT}" > $HOME/.kube/config
echo

echo "Done adding \"KubeConfig\" to \"$HOME/.kube/config\" ."
echo


newgrp docker << EOF

echo "Starting the runner via \"${ACTIONS_RUNNER_DIR}/run.sh &\" : "
echo

${ACTIONS_RUNNER_DIR}/run.sh &

EOF

tail -f /dev/null

#!/bin/bash

echo "Entering ${ACTIONS_RUNNER_DIR} ... "
echo

cd ${ACTIONS_RUNNER_DIR}

echo 'Current working directory is ...'
echo

pwd

echo
echo "##### BEGIN INSTALLING \"${GITHUB_RUNNER_NAME}\" ACTIONS RUNNER #####"
echo

echo "Installing actions runner under : "
pwd
echo

echo "Downloading and installing the actions-runner for ${GITHUB_REPO_URL} : "
echo

curl -o ${ACTIONS_RUNNER_INSTALL_FILENAME} -L ${ACTIONS_RUNNER_DOWNLOAD_URL}
tar xzf ./${ACTIONS_RUNNER_INSTALL_FILENAME}

echo
echo 'Creating answering file (answers.txt): '
echo

touch answers.txt
echo ${GITHUB_RUNNER_GROUP} >> answers.txt
echo ${GITHUB_RUNNER_NAME} >> answers.txt
echo ${GITHUB_RUNNER_LABELS} >> answers.txt
echo ${GITHUB_RUNNER_WORK_FOLDER} >> answers.txt

echo
echo 'answers.txt created: '
echo

cat answers.txt

echo
echo

./config.sh --url ${GITHUB_REPO_URL} --token ${GITHUB_REPO_TOKEN} < answers.txt

echo
echo "Changing all files under ${ACTIONS_RUNNER_DIR} to user ${RUNNER_USER_ID} :"
echo

sudo chown -R ${RUNNER_USER_ID}:${RUNNER_USER_ID} ${ACTIONS_RUNNER_DIR}

echo
echo "Verifying file ownership and permissions under ${ACTIONS_RUNNER_DIR} :"
echo

ls -al ${ACTIONS_RUNNER_DIR}

echo
echo "##### INSTALLING \"${GITHUB_RUNNER_NAME}\" ACTIONS RUNNER COMPLETED #####"
echo

echo "#####"
echo "Please switch the ENTRYPOINT script to ${ACTIONS_RUNNER_DIR}/entrypoint.sh"
echo "and restart the pod to start the runner"
echo "#####"
echo

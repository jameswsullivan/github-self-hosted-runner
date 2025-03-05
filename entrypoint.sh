#!/bin/bash

echo "Starting the runner via \"${ACTIONS_RUNNER_DIR}/run.sh &\" : "
echo

${ACTIONS_RUNNER_DIR}/run.sh &

EOF

tail -f /dev/null

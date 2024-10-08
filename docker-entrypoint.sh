#!/bin/bash

# Fetch environment variables.
GH_ORG=$GH_ORG
GH_TOKEN=$GH_TOKEN

# Generate a name for the runner.
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="photoatom-runner-${RUNNER_SUFFIX}"

# Fetch token for registering the runner.
REG_TOKEN=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/orgs/${GH_ORG}/actions/runners/registration-token" | jq .token --raw-output
)

# Register the runner.
cd /home/docker/actions-runner
./config.sh --unattended --url https://github.com/${GH_ORG} --token ${REG_TOKEN} --name ${RUNNER_NAME} --labels photoatom

# Function for cleaning up the runner.
cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner.
./run.sh & wait $!

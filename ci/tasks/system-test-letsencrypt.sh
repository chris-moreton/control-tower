#!/bin/bash

# shellcheck disable=SC1091
source concourse-up/ci/tasks/lib/verbose.sh

# shellcheck disable=SC1091
source concourse-up/ci/tasks/lib/id.sh

# shellcheck disable=SC1091
source concourse-up/ci/tasks/lib/pipeline.sh

# shellcheck disable=SC1091
source concourse-up/ci/tasks/lib/trap.sh

# shellcheck disable=SC1091
source concourse-up/ci/tasks/lib/letsencrypt.sh

handleVerboseMode

set -euo pipefail

# shellcheck disable=SC1091
source concourse-up/ci/tasks/lib/gcreds.sh

# If we're testing GCP, we need credentials to be available as a file
[ "$IAAS" = "GCP" ] && { setGoogleCreds; }

cp "$BINARY_PATH" ./cup
chmod +x ./cup

setDeploymentName crt

set +u
trapDefaultCleanup
set -u

echo "DEPLOY WITH LETSENCRYPT STAGING CERT, AND CUSTOM DOMAIN"

custom_domain="$deployment-auto-2.concourse-up.engineerbetter.com"

if [ "$IAAS" = "GCP" ]
then
  custom_domain="$deployment-auto-2.gcp.engineerbetter.com"
fi

export CONCOURSE_UP_ACME_URL=https://acme-staging.api.letsencrypt.org/directory # Avoid rate limits when testing
./cup deploy "$deployment" \
  --domain "$custom_domain"
sleep 60

config=$(./cup info --json "$deployment")
# shellcheck disable=SC2034
username=$(echo "$config" | jq -r '.config.concourse_username')
# shellcheck disable=SC2034
password=$(echo "$config" | jq -r '.config.concourse_password')
# shellcheck disable=SC2034
manifest="$(dirname "$0")/hello.yml"
# shellcheck disable=SC2034
job="hello"
# shellcheck disable=SC2034
domain="$custom_domain"

assertPipelineIsSettableAndRunnable

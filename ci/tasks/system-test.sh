#!/bin/bash

[ "$VERBOSE" ] && { set -x; export BOSH_LOG_LEVEL=debug; export BOSH_LOG_PATH=bosh.log; }
set -eu

deployment="system-test-$RANDOM"

cp "$BINARY_PATH" ./cup
chmod +x ./cup

echo "DEPLOY WITH AUTOGENERATED CERT, NO DOMAIN, DEFAULT WORKERS, AND DEFAULT DATABASE SIZE, AND DEFAULT WEB NODE SIZE"

./cup deploy $deployment

sleep 60

config=$(./cup info --json $deployment)
domain=$(echo "$config" | jq -r '.config.domain')
username=$(echo "$config" | jq -r '.config.concourse_username')
password=$(echo "$config" | jq -r '.config.concourse_password')
echo "$config" | jq -r '.config.concourse_ca_cert' > generated-ca-cert.pem

# Check RDS instance class is db.t2.small
rds_instance_class=$(aws --region eu-west-1 rds describe-db-instances | jq -r ".DBInstances[] | select(.DBSubnetGroup.DBSubnetGroupName==\"concourse-up-$deployment\") | .DBInstanceClass")
if [ "$rds_instance_class" != "db.t2.small" ]; then
  echo "Unexpected DB instance class: $rds_instance_class"
  exit 1
fi

fly --target system-test login \
  --ca-cert generated-ca-cert.pem \
  --concourse-url "https://$domain" \
  --username "$username" \
  --password "$password"

curl -k "https://$domain:3000"

fly --target system-test sync

fly --target system-test set-pipeline \
  --non-interactive \
  --pipeline hello \
  --config "$(dirname "$0")/hello.yml"

fly --target system-test unpause-pipeline \
    --pipeline hello

fly --target system-test trigger-job \
  --job hello/hello \
  --watch

echo "DEPLOY WITH AUTOGENERATED CERT, AND CUSTOM DOMAIN, 1 4xLARGE WORKERS, AND LARGE DB, AND MEDIUM WEB NODE"

custom_domain="$deployment-auto-2.concourse-up.engineerbetter.com"

./cup deploy $deployment \
  --domain $custom_domain \
  --worker-size 4xlarge \
  --web-size medium \
  --db-size large

sleep 60

# Check RDS instance class is db.m4.large
rds_instance_class=$(aws --region eu-west-1 rds describe-db-instances | jq -r ".DBInstances[] | select(.DBSubnetGroup.DBSubnetGroupName==\"concourse-up-$deployment\") | .DBInstanceClass")
if [ "$rds_instance_class" != "db.m4.large" ]; then
  echo "Unexpected DB instance class: $rds_instance_class"
  exit 1
fi

config=$(./cup info --json $deployment)
username=$(echo "$config" | jq -r '.config.concourse_username')
password=$(echo "$config" | jq -r '.config.concourse_password')
echo "$config" | jq -r '.config.concourse_ca_cert' > generated-ca-cert.pem

fly --target system-test-custom-domain login \
  --ca-cert generated-ca-cert.pem \
  --concourse-url https://$custom_domain \
  --username "$username" \
  --password "$password"

curl -k "https://$custom_domain:3000"

fly --target system-test-custom-domain sync

# Check that hello/hello job still exists and works
fly --target system-test-custom-domain trigger-job \
  --job hello/hello \
  --watch

echo "DEPLOY WITH USER PROVIDED CERT, 2 LARGE WORKERS"

custom_domain="$deployment-user.concourse-up.engineerbetter.com"

certstrap init \
  --common-name "$deployment" \
  --passphrase "" \
  --organization "" \
  --organizational-unit "" \
  --country "" \
  --province "" \
  --locality ""

certstrap request-cert \
   --passphrase "" \
   --domain $custom_domain

certstrap sign "$custom_domain" --CA "$deployment"

./cup deploy $deployment \
  --domain $custom_domain \
  --tls-cert "$(cat out/$custom_domain.crt)" \
  --tls-key "$(cat out/$custom_domain.key)" \
  --workers 2 \
  --worker-size large

sleep 60

# Check RDS instance class is still db.m4.large
rds_instance_class=$(aws --region eu-west-1 rds describe-db-instances | jq -r ".DBInstances[] | select(.DBSubnetGroup.DBSubnetGroupName==\"concourse-up-$deployment\") | .DBInstanceClass")
if [ "$rds_instance_class" != "db.m4.large" ]; then
  echo "Unexpected DB instance class: $rds_instance_class"
  exit 1
fi

config=$(./cup info --json $deployment)
username=$(echo "$config" | jq -r '.config.concourse_username')
password=$(echo "$config" | jq -r '.config.concourse_password')
echo "$config" | jq -r '.config.concourse_ca_cert' > generated-ca-cert.pem

fly --target system-test-custom-domain-with-cert login \
  --ca-cert out/$deployment.crt \
  --concourse-url https://$custom_domain \
  --username "$username" \
  --password "$password"

curl -k "https://$custom_domain:3000"

fly --target system-test-custom-domain-with-cert sync

# Check that hello/hello job still exists and works
fly --target system-test-custom-domain-with-cert trigger-job \
  --job hello/hello \
  --watch

echo "DESTROY"

./cup --non-interactive destroy $deployment

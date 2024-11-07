curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=API_KEY NEW_RELIC_ACCOUNT_ID=ACCOUNT_ID /usr/local/bin/newrelic install -y

docker run \
  --detach \
  --name newrelic-infra \
  --network=host \
  --cap-add=SYS_PTRACE \
  --privileged \
  --pid=host \
  --volume "/:/host:ro" \
  --volume "/var/run/docker.sock:/var/run/docker.sock" \
  --volume "newrelic-infra:/etc/newrelic-infra" \
  --env NRIA_LICENSE_KEY=API_KEY \
  newrelic/infrastructure:latest

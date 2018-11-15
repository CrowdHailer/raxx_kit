#!/usr/bin/env bash

set -eu
# https://stackoverflow.com/a/246128/246337
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo ""
echo "## generating a demo project"
echo ""

pushd $DIR/..
mix compile
mix raxx.kit --docker --ecto demo
popd

pushd $DIR/../demo

echo ""
echo "## starting all services"
echo ""

docker-compose up -d

echo ""
echo "## getting demo project dependencies inside the container"
echo ""

docker-compose run demo mix deps.get

echo ""
echo "## running tests for demo project inside the container"
echo ""

docker-compose run demo mix test

echo ""
echo "## make sure the demo service is still alive"
echo ""

# if the demo project has problems starting, the service
# will probably be dead by now
docker-compose exec demo echo "I'm still alive!"

# cleanup, for local docker_test runs
docker-compose down

popd

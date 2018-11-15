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
echo "## getting demo project dependencies inside the container"
echo ""

docker-compose run demo mix deps.get

echo ""
echo "## starting all services"
echo ""

docker-compose up -d

echo ""
echo "## running tests for demo project inside the container"
echo ""

docker-compose run demo mix test

# cleanup, for local docker_test runs
docker-compose down

popd

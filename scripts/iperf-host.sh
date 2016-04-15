#!/bin/bash -e

NS=${1:-test}

DOCKER_CONFIG=$(docker-machine config --swarm ${NS}-demo0)

echo Starting iperf server
docker ${DOCKER_CONFIG} run --name iperf_host -d -ti --net host \
    --env="constraint:node==${NS}-demo0" \
    mustafaakin/alpine-iperf iperf -s

# Wait a little
sleep 1

for run in {1..3}; do
    docker ${DOCKER_CONFIG} run --net host --env="constraint:node==${NS}-demo1" -ti \
    mustafaakin/alpine-iperf \
    iperf -c $(docker-machine ip ${NS}-demo0) -P 10 | grep SUM
done

docker ${DOCKER_CONFIG} rm -vf iperf_host

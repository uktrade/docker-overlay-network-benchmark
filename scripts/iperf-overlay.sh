#!/bin/bash -e

NS=${1:-test}

DOCKER_CONFIG=$(docker-machine config --swarm ${NS}-demo0)

echo Creating network
docker ${DOCKER_CONFIG} network create -d overlay mynet

echo Starting iperf server
docker ${DOCKER_CONFIG} run --name iperf_overlay -d -ti --net mynet \
    --env="constraint:node==${NS}-demo0" \
    mustafaakin/alpine-iperf iperf -s

# Wait a little
sleep 1

IP=$(docker ${DOCKER_CONFIG} inspect -f "{{ .NetworkSettings.Networks.mynet.IPAddress }}" iperf_overlay)
for run in {1..3}; do
    docker ${DOCKER_CONFIG} run --net mynet --env="constraint:node==${NS}-demo1" -ti \
    mustafaakin/alpine-iperf \
    iperf -c $IP -P 10 | grep SUM
done

docker ${DOCKER_CONFIG} rm -vf iperf_overlay
docker ${DOCKER_CONFIG} network rm mynet

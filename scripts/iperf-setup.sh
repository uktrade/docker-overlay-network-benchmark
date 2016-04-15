#!/bin/bash -e

NS=${1:-test}
DRIVER=${2:-amazonec2}

# Create Key Store Node
docker-machine create --driver ${DRIVER} ${NS}-keystore

docker $(docker-machine config ${NS}-keystore) run -d \
    -p "8500:8500" \
    -h "consul" \
    progrium/consul -server -bootstrap

# Create Primary Node
docker-machine create \
    --driver ${DRIVER} \
    --swarm --swarm-master \
    --swarm-discovery="consul://$(docker-machine ip ${NS}-keystore):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip ${NS}-keystore):8500" \
    --engine-opt="cluster-advertise=eth0:2376" \
    ${NS}-demo0 &

# Create Secondary Node
docker-machine create \
    --driver ${DRIVER} \
    --swarm \
    --swarm-discovery="consul://$(docker-machine ip ${NS}-keystore):8500" \
    --engine-opt="cluster-store=consul://$(docker-machine ip ${NS}-keystore):8500" \
    --engine-opt="cluster-advertise=eth0:2376" \
    ${NS}-demo1 &

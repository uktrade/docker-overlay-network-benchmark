#!/bin/bash

NS=${1:-test}

docker-machine rm -f ${NS}-keystore
docker-machine rm -f ${NS}-demo0
docker-machine rm -f ${NS}-demo1

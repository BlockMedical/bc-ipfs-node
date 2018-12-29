#!/bin/bash

CURR_DIR=$(cd $(dirname $0); pwd)

TAG_BRANCH=${TAG_BRANCH:-"v0.0.7"}

IPFS_DIR="$CURR_DIR/data"
mkdir -p $IPFS_DIR
chmod -R 777 $IPFS_DIR

docker run --rm -d \
  --publish 5001:5001 \
  --publish 8080:8080 \
  --env IPFS_PATH=/home/ipfsuser/ipfs \
  --mount type=bind,source=$IPFS_DIR,target=/home/ipfsuser/ipfs \
  blcksync/bc-ipfs-node:${TAG_BRANCH}

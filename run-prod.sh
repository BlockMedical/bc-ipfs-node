#!/bin/bash

CURR_DIR=$(cd $(dirname $0); pwd)

BUILD_BRANCH=${BUILD_BRANCH:-"blcksync-v0.4.18"}

IPFS_DIR="$CURR_DIR/data"
rm -rf $IPFS_DIR
mkdir -p $IPFS_DIR
chmod -R 777 $IPFS_DIR

docker run --rm -d \
  --publish 5001:5001 \
  --publish 8080:8080 \
  --env IPFS_PATH=/home/ipfsuser/ipfs \
  --mount type=bind,source=$IPFS_DIR,target=/home/ipfsuser/ipfs \
  blcksync/bc-ipfs-node:${BUILD_BRANCH}

#!/bin/bash -x

DEBUG=${DEBUG:-"true"}
build_cmd="docker build "

if [ "$DEBUG" != "true" ] ; then
  build_cmd="docker build --no-cache"
fi

TAG_BRANCH=${TAG_BRANCH:-"v0.0.7"}

# Build base blcksync/alpine-node:latest image
$build_cmd \
  --rm \
  -t blcksync/bc-ipfs-node:${TAG_BRANCH} \
  --file Dockerfile \
  .

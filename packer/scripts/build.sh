#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 NAME"
    exit 1
fi

NAME=$1

package_check () {
    command -v aws > /dev/null || (echo "aws cli must be installed" && exit 1)
    command -v packer > /dev/null || (echo "packer must be installed" && exit 1)
    command -v git > /dev/null || (echo "git must be installed" && exit 1)
    command -v jq > /dev/null || (echo "jq must be installed" && exit 1)
}

# check that the tools we require are present
package_check

# Use machine readable output to send this data to the log
echo "Starting packer build for $NAME"
packer build -machine-readable ./packer/${NAME}.json | tee build.log
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  echo "Something went wrong with the packer build."
  exit ${PIPESTATUS[0]}
fi

# Parse out the AMI from the log output
# TODO: Replace this business with a post-processor and jq
# https://www.packer.io/docs/post-processors/manifest.html
AMI=$(awk -F, '$0 ~/artifact,0,id/ {print $6}' build.log)
echo ${AMI##*:} > /tmp/workspace/${NAME}_ami_id
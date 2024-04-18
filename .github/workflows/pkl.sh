#!/bin/bash
#
# Create pkl release

set -eoux pipefail

# refs/tags/cloudformation@0.1.0-test1
echo "GITHUB_REF: ${GITHUB_REF}"

FIXED_REF=${GITHUB_REF##*/}
# cloudformation@0.1.0-test1
echo "FIXED_REF: ${FIXED_REF}"

SEMVER=$(echo ${FIXED_REF} | sed s/^cloudformation@//g)
# 0.1.0-test1
echo "SEMVER: ${SEMVER}"

curl -L -o /tmp/pkl https://github.com/apple/pkl/releases/download/0.25.3/pkl-linux-amd64
chmod +x /tmp/pkl
/tmp/pkl --version

# Modify the PklProject file

cat package/PklProject-template| sed s/VERSION/${SEMVER}/g > package/PklProject

/tmp/pkl project package package
gh release upload "${FIXED_REF}" .out/cloudformation@${SEMVER}/*


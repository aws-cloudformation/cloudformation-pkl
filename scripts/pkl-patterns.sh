#!/usr/local/bin/bash

set -eou pipefail

echo "Bucket..."
pkl eval test/bucket.pkl | rain fmt | cfn-lint

echo "VPC..."
pkl eval test/vpc-pattern.pkl -f yaml | rain fmt | cfn-lint

echo "Lambda..."
pkl eval test/lambda.pkl -f yaml | rain fmt | cfn-lint -i E3002


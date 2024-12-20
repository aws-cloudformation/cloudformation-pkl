#!/usr/local/bin/bash

set -eou pipefail

echo "Building pkl classes..."

rain build -l | grep "^AWS::" | grep -v "^AWS::QuickSight" | xargs -n1 scripts/gen-one-pkl.sh

echo "Testing patterns..."
./scripts/pkl-patterns.sh

echo "Success!"

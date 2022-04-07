#!/bin/bash

set -e

echo "Cleaning old files..."
rm -rf bin
mkdir bin
pushd bin >/dev/null 
touch .keep
popd >/dev/null
pushd third_party/Integrated_Patcher_3 >/dev/null
make clean
popd >/dev/null
echo "Done!"

exit 0

#!/bin/bash

set -x
set -e


pushd clinical  ; ./load.sh; popd
pushd expression; ./load.sh; popd

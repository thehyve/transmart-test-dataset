#!/bin/bash

set -x
set -e

pushd annotation; ./load.sh; popd
load_expression.sh

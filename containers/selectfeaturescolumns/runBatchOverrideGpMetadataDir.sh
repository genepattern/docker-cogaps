#!/bin/sh
# test with override of the $GP_METADATA_DIR

. runConfig.sh
export GP_METADATA_DIR=$WORKING_DIR/meta
mkdir -p $GP_METADATA_DIR

export STDOUT_FILENAME=foo.stdout.txt

. ../../common/testing_scripts/runOnBatch.sh


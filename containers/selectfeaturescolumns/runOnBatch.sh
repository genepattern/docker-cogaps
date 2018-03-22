#!/bin/sh
echo "Config for $i -- $@"
. runConfig.sh $@
. runOnBatchInner.sh $@


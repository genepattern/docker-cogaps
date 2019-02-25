#!/bin/bash

# this file runs through a bunch of test cases by directly calling the Rscript
# which drives the module

CMD="--no-save --quiet --slave --no-restore \
    ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --transpose.data=TRUE \
"

declare -a tests=(
                  "$CMD"
                  "$CMD --transpose-data=TRUE"
                  "$CMD --num.threads=2"
                  "$CMD --param.file=data/test-params.rds"
                  "$CMD --param.file=data/test-params-gw.rds"
                  "$CMD --param.file=data/test-params-sc.rds --transpose.data=TRUE"
                 )

for tst in "${tests[@]}"
do
    Rscript $tst
done

rm -f test-output.rds
rm -f gaps_checkpoint.out

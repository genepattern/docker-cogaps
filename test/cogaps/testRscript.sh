#!/bin/bash

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --transpose.data=TRUE

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --num.threads=2

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --param.file=data/test-params.rds

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --param.file=data/test-params-gw.rds

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --data.file=data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --param.file=data/test-params-sc.rds \
    --transpose.data=TRUE

rm -f test-output.rds
rm -f gaps_checkpoint.out

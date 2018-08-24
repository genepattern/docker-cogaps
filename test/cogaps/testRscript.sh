#!/bin/bash

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R \
    --input.file=data/all_aml_test.gct \
    --transpose.data=false \
    --pattern.start=2 \
    --pattern.stop=4 \
    --pattern.step=1 \
    --num.iterations=1000 \
    --seed=123 \
    --single.cell=false \
    --distributed.method=none \
    --num.sets=4 \
    --num.threads=1 \
    --output.file=testLocalOutputs
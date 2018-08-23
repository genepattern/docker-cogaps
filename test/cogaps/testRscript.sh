#!/bin/bash

Rscript --no-save --quiet --slave --no-restore ../../src/run_cogaps_module.R --input.file=data/all_aml_test.gct  --num.iterations=1000 --num.sets=4  --pattern.start=2 --pattern.stop=4 --pattern.step=1  --seed=123   --output.file=testLocalOutputs
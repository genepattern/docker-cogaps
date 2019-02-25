#!/bin/bash

# this file runs through a bunch of test cases by first creating a local build
# of the docker image, and then running the docker image with each test case

docker build -t cogaps_module ../..

LOCAL_DIR=$PWD
CMD="Rscript --no-save --quiet --slave --no-restore \
    /usr/local/bin/cogaps/run_cogaps_module.R \
    --data.file=$LOCAL_DIR/data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    --transpose.data=TRUE \
"

declare -a tests=(
                  "$CMD"
                  "$CMD --transpose-data=TRUE"
                  "$CMD --num.threads=2"
                  "$CMD --github.tag=v3.3.39"
                  "$CMD --param.file=$LOCAL_DIR/data/test-params.rds"
                  "$CMD --param.file=$LOCAL_DIR/data/test-params-gw.rds"
                  "$CMD --param.file=$LOCAL_DIR/data/test-params-sc.rds --transpose.data=TRUE"
                 )

for tst in "${tests[@]}"
do
    docker run -v $LOCAL_DIR:$LOCAL_DIR -t cogaps_module $tst
done


#!/bin/bash

START_NUM=$1
NUM_TESTS=$2
echo "Checking $START_NUM to $NUM_TESTS SFC Jobs"

for i in `seq $START_NUM $NUM_TESTS`;
do
    cd test_$i
    . runConfig.sh
    
    aws s3 sync $S3_ROOT$WORKING_DIR $WORKING_DIR --quiet --profile genepattern
    
    #ls -lrt ./job_1/testout$i.gct
    if [ ! -f ./job_1/testout$i.gct ]; then
        echo "$i. File not found"
    else
        echo "$i OK" 
    fi
    cd ..
done 


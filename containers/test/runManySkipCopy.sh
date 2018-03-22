#!/bin/sh
START_NUM=$1
NUM_TESTS=$2

echo "Running from existing $START_NUM to $NUM_TESTS SFC Jobs"

for i in `seq $START_NUM $NUM_TESTS`;
do
    echo $i
    #mkdir -p test_$i
    #cp -r ../selectfeaturescolumns/* test_$i
    #rm -rf test_$i/job_1/*
    cd test_$i
    #mv data/all_aml_train.gct data/all_aml_train$i.gct
    . runOnBatch.sh _$i
    cd ..
done 


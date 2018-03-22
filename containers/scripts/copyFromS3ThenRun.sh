#!/bin/bash
#
# &copy; 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.
#

# strip off spaces if present
TASKLIB="$(echo -e "${1}" | tr -d '[:space:]')"
INPUT_FILES_DIR="$(echo -e "${2}" | tr -d '[:space:]')"
S3_ROOT="$(echo -e "${3}" | tr -d '[:space:]')"
WORKING_DIR="$(echo -e "${4}" | tr -d '[:space:]')"
EXECUTABLE=$5


# make a directory into which we will S3 sync everything we have had passed in to the 'outer' container
# this will NOT be at the same path as on the GP head node and the compute node, but it will be mounted to the
# inner container using the same path as on the head node
#
# Note we need to coordinate with Peter to ensure he doesn't do additional S3 commands in the inner container
# in the generated exec.sh script
#
# /local on the compute node should be mounted to /local in this (outer) container
#
LOCAL_DIR_ON_HOST=/local
LOCAL_DIR=/local
mkdir -p $LOCAL_DIR/Users/liefeld/GenePattern

#
# assign filenames for STDOUT and STDERR if not already set
#
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${STDOUT_FILENAME=$GP_METADATA_DIR/stdout.txt}
: ${STDERR_FILENAME=$GP_METADATA_DIR/stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

# echo out params
#echo DIND Task dir is -$TASKLIB-   $1
#echo DIND input files location  is -$INPUT_FILES_DIR-  $2
#echo DIND S3_ROOT is -$S3_ROOT-  $3
#echo DIND working dir is  -$WORKING_DIR-  $4
#echo DIND executable is -$5-  
chmod a+x $5

# copy the source over from tasklib
mkdir -p $TASKLIB
echo "1. PERFORMING AWS SYNC $S3_ROOT$TASKLIB $LOCAL_DIR/$TASKLIB"
aws s3 sync $S3_ROOT$TASKLIB $LOCAL_DIR/$TASKLIB --quiet
ls $LOCAL_DIR/$TASKLIB

# copy the inputs
mkdir -p $INPUT_FILES_DIR
echo "2. PERFORMING aws s3 sync $S3_ROOT$INPUT_FILES_DIR $LOCAL_DIR/$INPUT_FILES_DIR"
aws s3 sync $S3_ROOT$INPUT_FILES_DIR $LOCAL_DIR/$INPUT_FILES_DIR --quiet
ls $LOCAL_DIR/$INPUT_FILES_DIR

echo "=========  what data is on this machine =========="
find $LOCAL_DIR -name "test_*" 
echo "========= what containers are running "
docker ps

# switch to the working directory and sync it up
echo "3. PERFORMING aws s3 sync $S3_ROOT$WORKING_DIR $LOCAL_DIR/$WORKING_DIR "
aws s3 sync $S3_ROOT$WORKING_DIR $LOCAL_DIR/$WORKING_DIR --quiet

echo "3a synching gp_metadata_dir"
aws s3 sync $S3_ROOT$GP_METADATA_DIR $LOCAL_DIR/$GP_METADATA_DIR 

cd $LOCAL_DIR/$WORKING_DIR
echo "3b. chmodding $GP_METADATA_DIR from $PWD"
chmod a+rwx $LOCAL_DIR/$GP_METADATA_DIR/*
ls -alrt

echo "========== S3 copies in complete, DEBUG inside 1st container ================="

. /usr/local/bin/runLocalOnBatch.sh $@

echo "====== END RUNNING Module, copy back from S3  ================="

# send the generated files back
echo "5. PERFORMING aws s3 sync $LOCAL_DIR/$WORKING_DIR $S3_ROOT$WORKING_DIR"
aws s3 sync $LOCAL_DIR/$WORKING_DIR $S3_ROOT$WORKING_DIR 

echo "6. PERFORMING aws s3 sync $LOCAL_DIR/$TASKLIB $S3_ROOT$TASKLIB"
aws s3 sync $LOCAL_DIR/$TASKLIB $S3_ROOT$TASKLIB --quiet
echo "7. PERFORMING aws s3 sync  $LOCAL_DIR/$GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR"
aws s3 sync  $LOCAL_DIR/$GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR --quiet

#
# allow customization for specific images - eg to save RLIBS back to S3 for reuse
#
#if [ -f "/usr/local/bin/runS3Batch_postrun_custom.sh" ]; then
#   . /usr/local/bin/runS3Batch_postrun_custom.sh
#fi






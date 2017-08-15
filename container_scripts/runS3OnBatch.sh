#!/bin/bash

# strip off spaces if present
TASKLIB="$(echo -e "${1}" | tr -d '[:space:]')"
INPUT_FILES_DIR="$(echo -e "${2}" | tr -d '[:space:]')"
S3_ROOT="$(echo -e "${3}" | tr -d '[:space:]')"
WORKING_DIR="$(echo -e "${4}" | tr -d '[:space:]')"
EXECUTABLE=$5

#
# assign filenames for STDOUT and STDERR if not already set
#
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${STDOUT_FILENAME=$GP_METADATA_DIR/stdout.txt}
: ${STDERR_FILENAME=$GP_METADATA_DIR/stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

# echo out params, this should end up only in the cloudwatch logs
echo working dir is  -$WORKING_DIR- 
echo metadata dir is: -$GP_METADATA_DIR-
echo Task dir is -$TASKLIB-
echo executable is -$5-
echo S3_ROOT is -$S3_ROOT-
echo input files location  is -$INPUT_FILES_DIR-

echo STDOUT_FILENAME is -$STDOUT_FILENAME-
echo STDERR_FILENAME is -$STDERR_FILENAME-
echo EXITCODE_FILENAME is -$EXITCODE_FILENAME-

# copy the source over from tasklib
mkdir -p $TASKLIB
echo "1. PERFORMING AWS SYNC $S3_ROOT$TASKLIB $TASKLIB"
aws s3 sync $S3_ROOT$TASKLIB $TASKLIB --quiet
ls $TASKLIB

 
# copy the inputs
mkdir -p $INPUT_FILES_DIR
echo "2. PERFORMING aws s3 sync $S3_ROOT$INPUT_FILES_DIR $INPUT_FILES_DIR"
aws s3 sync $S3_ROOT$INPUT_FILES_DIR $INPUT_FILES_DIR --quiet
ls $INPUT_FILES_DIR

# switch to the working directory and sync it up
echo "3. PERFORMING aws s3 sync $S3_ROOT$WORKING_DIR $WORKING_DIR "
aws s3 sync $S3_ROOT$WORKING_DIR $WORKING_DIR --quiet

echo "3a synching gp_metadata_dir"
aws s3 sync $S3_ROOT$GP_METADATA_DIR $GP_METADATA_DIR 

cd $WORKING_DIR
echo "3b. chmodding $GP_METADATA_DIR from $PWD"
chmod a+rwx $GP_METADATA_DIR/*


# run the module
echo "4. PERFORMING $5"
$5 >$STDOUT_FILENAME 2>$STDERR_FILENAME
echo "{ \"exit_code\": $? }">$EXITCODE_FILENAME

# send the generated files back
echo "5. PERFORMING aws s3 sync $WORKING_DIR $S3_ROOT$WORKING_DIR"
aws s3 sync $WORKING_DIR $S3_ROOT$WORKING_DIR --quiet
echo "6. PERFORMING aws s3 sync $TASKLIB $S3_ROOT$TASKLIB"
aws s3 sync $TASKLIB $S3_ROOT$TASKLIB --quiet
echo "7. PERFORMING aws s3 sync  $GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR"
aws s3 sync  $GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR --quiet




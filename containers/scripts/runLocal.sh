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

#
# assign filenames for STDOUT and STDERR if not already set
#
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${STDOUT_FILENAME=stdout.txt}
: ${STDERR_FILENAME=stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

# echo out params
echo DIND-2 Task dir is -$TASKLIB-   $1
echo DIND-2 input files location  is -$INPUT_FILES_DIR-  $2
echo DIND-2 S3_ROOT is -$S3_ROOT-  $3
echo DIND-2 working dir is  -$WORKING_DIR-  $4
echo DIND-2 executable is -$EXECUTABLE-  

cd $LOCAL_DIR$WORKING_DIR

echo "========== DEBUG inside 1st container, runLocal.sh - running module now  ================="

echo PERFORMING:  docker run -e GP_METADATA_DIR="$GP_METADATA_DIR" -e STDOUT_FILENAME=$STDOUT_FILENAME -e STDERR_FILENAME=$STDERR_FILENAME -v /var/run/docker.sock:/var/run/docker.sock  -v $LOCAL_DIR$GP_METADATA_DIR:$GP_METADATA_DIR -v $LOCAL_DIR$TASKLIB:$TASKLIB -v $LOCAL_DIR$INPUT_FILES_DIR:$INPUT_FILES_DIR -v $LOCAL_DIR$WORKING_DIR:$WORKING_DIR  -e DOCKER_CONTAINER=$DOCKER_CONTAINER -t $DOCKER_CONTAINER sh $EXECUTABLE  >$STDOUT_FILENAME 2>$STDERR_FILENAME


docker run -e GP_METADATA_DIR="$GP_METADATA_DIR" -e STDOUT_FILENAME=$STDOUT_FILENAME -e STDERR_FILENAME=$STDERR_FILENAME -v /var/run/docker.sock:/var/run/docker.sock  -v $LOCAL_DIR$GP_METADATA_DIR:$GP_METADATA_DIR -v $LOCAL_DIR$TASKLIB:$TASKLIB -v $LOCAL_DIR$INPUT_FILES_DIR:$INPUT_FILES_DIR -v $LOCAL_DIR$WORKING_DIR:$WORKING_DIR  -e DOCKER_CONTAINER=$DOCKER_CONTAINER -t $DOCKER_CONTAINER sh $EXECUTABLE >$STDOUT_FILENAME 2>$STDERR_FILENAME

 
echo "====== rulLocal.sh END of running module  ================="





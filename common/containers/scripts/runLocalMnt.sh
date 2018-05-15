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
echo LOCAL_DIR is $LOCAL_DIR

#
# assign filenames for STDOUT and STDERR if not already set
#
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${STDOUT_FILENAME=stdout.txt}
: ${STDERR_FILENAME=stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

# we need a no-op default for MOD_LIBS
: ${MOD_LIBS=$GP_METADATA_DIR}
: ${MOD_LIBS_S3=$GP_METADATA_DIR}

echo DIND-2 MOD_LIBS is $MOD_LIBS
echo DIND-2 MOD_LIBS_S3 is $MOD_LIBS_S3

cd $LOCAL_DIR$WORKING_DIR

echo "========== DEBUG inside 1st container, runLocal.sh - running module now  ================="

echo "==PERFORMING==> docker run -e GP_METADATA_DIR="$GP_METADATA_DIR" -e STDOUT_FILENAME=$STDOUT_FILENAME -e STDERR_FILENAME=$STDERR_FILENAME -v /var/run/docker.sock:/var/run/docker.sock  -v $LOCAL_DIR$GP_METADATA_DIR:$GP_METADATA_DIR -v $LOCAL_DIR$MOD_LIBS:$MOD_LIBS -v $LOCAL_DIR$TASKLIB:$TASKLIB -v $LOCAL_DIR$INPUT_FILES_DIR:$INPUT_FILES_DIR -v $LOCAL_DIR$WORKING_DIR:$WORKING_DIR  -e DOCKER_CONTAINER=$DOCKER_CONTAINER -w $WORKING_DIR -t $DOCKER_CONTAINER sh $EXECUTABLE >$STDOUT_FILENAME 2>$STDERR_FILENAME "

# pull first so that the stderr.txt is not polluted by the output of docker getting the image
docker pull $DOCKER_CONTAINER

docker run -e GP_METADATA_DIR="$GP_METADATA_DIR" -e STDOUT_FILENAME=$STDOUT_FILENAME -e STDERR_FILENAME=$STDERR_FILENAME -v $LOCAL_DIR/opt/gpbeta/gp_home/users/:/opt/gpbeta/gp_home/users/ -v /var/run/docker.sock:/var/run/docker.sock  -v $LOCAL_DIR$GP_METADATA_DIR:$GP_METADATA_DIR -v $LOCAL_DIR$MOD_LIBS:$MOD_LIBS -v $LOCAL_DIR$TASKLIB:$TASKLIB -v $LOCAL_DIR$INPUT_FILES_DIR:$INPUT_FILES_DIR -v $LOCAL_DIR$WORKING_DIR:$WORKING_DIR  -e DOCKER_CONTAINER=$DOCKER_CONTAINER -w $WORKING_DIR -t $DOCKER_CONTAINER sh $EXECUTABLE >$LOCAL_DIR$STDOUT_FILENAME 2>$LOCAL_DIR$STDERR_FILENAME

 
echo "====== runLocal.sh END of running module  ================="





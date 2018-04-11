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

cd $LOCAL_DIR$WORKING_DIR

echo "========== DEBUG inside 1st container, runLocal.sh - running module now  ================="

# pull first so that the stderr.txt is not polluted by the output of docker getting the image
docker pull $DOCKER_CONTAINER

# start the container with an endless loop
# copy the desired dirs into it
# run the module command
# copy the contents back out to the local disk

CONTAINER_ID="`docker run -d -t $DOCKER_CONTAINER sleep 1d`"

docker exec $CONTAINER_ID mkdir -p $GP_METADATA_DIR
docker cp $LOCAL_DIR$GP_METADATA_DIR/. $CONTAINER_ID:$GP_METADATA_DIR
docker exec $CONTAINER_ID mkdir -p $MOD_LIBS
docker cp $LOCAL_DIR$MOD_LIBS/. $CONTAINER_ID:$MOD_LIBS
docker exec $CONTAINER_ID mkdir -p $TASKLIB
docker cp $LOCAL_DIR$TASKLIB/. $CONTAINER_ID:$TASKLIB
docker exec $CONTAINER_ID mkdir -p $WORKING_DIR
docker cp $LOCAL_DIR$WORKING_DIR/. $CONTAINER_ID:$WORKING_DIR
docker exec $CONTAINER_ID mkdir -p $INPUT_FILES_DIR
docker cp $LOCAL_DIR$INPUT_FILES_DIR/. $CONTAINER_ID:$INPUT_FILES_DIR
echo docker cp are done - executing the command $EXECUTABLE now

docker exec -e GP_METADATA_DIR="$GP_METADATA_DIR" -w $WORKING_DIR -t $CONTAINER_ID sh $EXECUTABLE >$LOCAL_DIR$STDOUT_FILENAME 2>$LOCAL_DIR$STDERR_FILENAME

echo Module execution complete, copying files back

docker cp $CONTAINER_ID:$GP_METADATA_DIR/. $LOCAL_DIR$GP_METADATA_DIR
docker cp $CONTAINER_ID:$MOD_LIBS/. $LOCAL_DIR$MOD_LIBS
docker cp $CONTAINER_ID:$TASKLIB/. $LOCAL_DIR$TASKLIB
docker cp $CONTAINER_ID:$WORKING_DIR/. $LOCAL_DIR$WORKING_DIR
docker cp $CONTAINER_ID:$INPUT_FILES_DIR/. $LOCAL_DIR$INPUT_FILES_DIR

# now remove the inputs and outputs before we save the image
docker exec $CONTAINER_ID rm -rf $WORKING_DIR $INPUT_FILES_DIR $GP_METADATA_DIR
docker stop $CONTAINER_ID


echo "now try to save container"
/usr/local/bin/saveContainerInECR.sh





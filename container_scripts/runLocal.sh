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
: ${STDOUT_FILENAME=stdout.txt}
: ${STDERR_FILENAME=stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

# echo out params
echo working dir is  -$WORKING_DIR- 
echo Task dir is -$TASKLIB-
echo executable is -$5-
echo S3_ROOT is -$S3_ROOT-
echo input files location  is -$INPUT_FILES_DIR-
echo STDOUT is $STDOUT_FILENAME

##################################################
# MODIFICATION FOR R PACKAGE INSTALLATION
##################################################
if [[ -f "$TASKLIB/r.package.info"  && -f "/build/source/installPackages.R" ]]
then
        echo "Installing R packages from $TASKLIB/r.package.info."
        Rscript /build/source/installPackages.R $TASKLIB/r.package.info
else
        echo "No R packages installed. $TASKLIB/r.package.info not found."
fi


cd $WORKING_DIR

# run the module
shift
shift
shift
shift

echo "========== DEBUG inside container ================="
echo $@  >$STDOUT_FILENAME 2>$STDERR_FILENAME
echo "{ \"exit_code\": $? }">$EXITCODE_FILENAME
echo "====== END DEBUG ================="

"$@"  >$STDOUT_FILENAME 2>$STDERR_FILENAME




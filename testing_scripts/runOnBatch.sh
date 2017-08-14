#!/bin/sh

# set gp_metadata if unset
: ${GP_METADATA_DIR=$WORKING_DIR/.gp_metadata}
: ${STDOUT_FILENAME=stdout.txt}
: ${STDERR_FILENAME=stderr.txt}
: ${EXITCODE_FILENAME=$GP_METADATA_DIR/exit_code.txt}

: ${S3_ROOT=s3://moduleiotest}
: ${JOB_QUEUE=TedTest}

cd $TEST_ROOT

# ##### NEW PART FOR SCRIPT INSTEAD OF COMMAND LINE ################################
# Make the input file directory since we need to put the script to execute in it
mkdir -p $GP_METADATA_DIR

EXEC_SHELL=$GP_METADATA_DIR/exec.sh

echo "#!/bin/bash\n" > $EXEC_SHELL
#echo "echo \"$COMMAND_LINE\"" >>$EXEC_SHELL
echo $COMMAND_LINE >>$EXEC_SHELL 
echo "\n " >>$EXEC_SHELL 

chmod a+rwx $EXEC_SHELL
chmod -R a+rwx $WORKING_DIR

REMOTE_COMMAND=$EXEC_SHELL
# note the batch submit now uses REMOTE_COMMAND instead of COMMAND_LINE 

#
# Copy the input files to S3 using the same path
#
aws s3 sync $INPUT_FILE_DIRECTORIES $S3_ROOT$INPUT_FILE_DIRECTORIES --profile genepattern
aws s3 sync $TASKLIB $S3_ROOT$TASKLIB --profile genepattern
aws s3 sync $WORKING_DIR $S3_ROOT$WORKING_DIR --profile genepattern 
aws s3 sync $GP_METADATA_DIR $S3_ROOT$GP_METADATA_DIR --profile genepattern 

######### end new part for script #################################################


#       --container-overrides memory=2000 \

aws batch submit-job \
      --job-name $JOB_ID \
      --job-queue $JOB_QUEUE \
      --container-overrides "memory=3600,environment=[{name=GP_METADATA_DIR,value=$GP_METADATA_DIR},{name=STDOUT_FILENAME,value=$STDOUT_FILENAME},{name=STDERR_FILENAME,value=$STDERR_FILENAME},{name=EXITCODE_FILENAME,value=$EXITCODE_FILENAME}]"  \
      --job-definition $JOB_DEFINITION_NAME \
      --parameters taskLib=$TASKLIB,inputFileDirectory=$INPUT_FILE_DIRECTORIES,s3_root=$S3_ROOT,working_dir=$WORKING_DIR,exe1="$REMOTE_COMMAND"  \
      --profile genepattern



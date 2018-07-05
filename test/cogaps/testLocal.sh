# quick test of CoGAPS in container

# immediately below cached from exec.sh on gp-beta-ami
#COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore /usr/local/bin/cogaps/run_cogaps_module.R --input.file=/opt/gpbeta/gp_home/users/ted-dev/uploads/tmp/run3397151060806753738.tmp/input.file/1/all_aml_test.gct --stddev.decimal.value=0.1 --num.iterations=500 --pattern.range=2:4:1 --seed=123 --output.file=all_aml_test.incremented.gct "

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore  /usr/local/bin/cogaps/run_cogaps_module.R   --input.file=/Users/liefeld/GenePattern/gp_dev/docker/docker-cogaps/test/cogaps/data/all_aml_test.gct  --stddev.decimal.value=0.1   --num.iterations=1000  --pattern.start=2 --pattern.stop=4 --pattern.step=1  --seed=123   --output.file=testLocalOutputs"

LOCAL_DIR=$PWD

docker run -v $LOCAL_DIR:$LOCAL_DIR -w $LOCAL_DIR/Job_3113 -t genepattern/docker-cogaps $COMMAND_LINE

#docker run -v $LOCAL_DIR:$LOCAL_DIR -w $LOCAL_DIR genepattern/docker-cogaps ls



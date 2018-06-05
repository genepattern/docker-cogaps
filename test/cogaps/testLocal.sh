# quick test of CoGAPS in container

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore  /usr/local/bin/cogaps/run_cogaps_module.R   --input.file=/Users/liefeld/GenePattern/gp_dev/docker/docker-cogaps/test/cogaps/data/all_aml_test.gct  --stddev.decimal.value=0.1   --num.iterations=1000  --pattern.range=2:4  --seed=123   --output.file=testLocalOutputs"

LOCAL_DIR=$PWD

docker run -v $LOCAL_DIR:$LOCAL_DIR -w $LOCAL_DIR -t genepattern/docker-cogaps $COMMAND_LINE

#docker run -v $LOCAL_DIR:$LOCAL_DIR -w $LOCAL_DIR genepattern/docker-cogaps ls



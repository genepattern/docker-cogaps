# quick test of CoGAPS in container

LOCAL_DIR=$PWD

#COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore  /usr/local/bin/cogaps/run_cogaps_module.R   --input.file=$LOCAL_DIR/data/all_aml_test.gct --param.file=$LOCAL_DIR/data/default_cogaps_params.rds --num.threads=4 --single.cell= FALSE --distributed.method=none --transpose.data=FALSE  --stddev.decimal.value=0.1   --num.iterations=1000  --pattern.start=2 --pattern.stop=4 --pattern.step=1  --seed=123   --output.file=testLocalOutputs --num.sets=5 "

#COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore  /usr/local/bin/cogaps/run_cogaps_module.R   --data.file=$LOCAL_DIR/data/all_aml_test.gct --param.file=$LOCAL_DIR/data/default_cogaps_params.rds --n.threads=4 --transpose.data=FALSE --output.file=testLocalOutputs"  

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore  /usr/local/bin/cogaps/run_cogaps_module.R   --data.file=$LOCAL_DIR/data/all_aml_test.gct --param.file=$LOCAL_DIR/data/default_cogaps_params.rds --n.patterns=10 --n.threads=4 --transpose.data=FALSE --output.file=testLocalOutputs"  


echo $COMMAND_LINE
docker run -v $LOCAL_DIR:$LOCAL_DIR -w $LOCAL_DIR/Job_3113 -t genepattern/docker-cogaps:v0.6a $COMMAND_LINE




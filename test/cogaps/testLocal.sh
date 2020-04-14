# quick test of CoGAPS in container

LOCAL_DIR=$PWD

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore    /usr/local/bin/cogaps/run_cogaps_module.R   --data.file=$LOCAL_DIR/data/GIST.gct  --output.file=test-output --num.patterns=3 --num.iterations=5000 --transpose.data=TRUE --param.file=$LOCAL_DIR/data/test-params.rds"


echo $COMMAND_LINE
docker run -v $LOCAL_DIR:$LOCAL_DIR -w $LOCAL_DIR/Job_3113 -t genepattern/docker-cogaps:0.9 $COMMAND_LINE




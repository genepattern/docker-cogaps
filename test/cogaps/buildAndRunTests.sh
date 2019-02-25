LOCAL_DIR=$PWD

COMMAND_LINE="Rscript --no-save --quiet --slave --no-restore \
    /usr/local/bin/cogaps/run_cogaps_module.R \
    --data.file=/data/GIST.gct \
    --output.file=test-output \
    --num.patterns=3 \
    --num.iterations=5000 \
    "

docker build -t cogaps_module ../..

docker run -v $LOCAL_DIR/data:/data -t cogaps_module $COMMAND_LINE



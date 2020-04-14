## The Regents of the University of California and The Broad Institute
## SOFTWARE COPYRIGHT NOTICE AGREEMENT
## This software and its documentation are copyright (2018) by the
## Regents of the University of California abd the 
## Broad Institute/Massachusetts Institute of Technology. All rights are
## reserved.
##
## This software is supplied without any warranty or guaranteed support
## whatsoever. Neither the Broad Institute nor MIT can be responsible for its
## use, misuse, or functionality.

# Load any packages used to in our code to interface with GenePattern.
# Note the use of suppressMessages and suppressWarnings here. The package
# loading process is often noisy on stderr, which will (by default) cause
# GenePattern to flag the job as failing even when nothing went wrong. 
suppressMessages(suppressWarnings(library(getopt)))
suppressMessages(suppressWarnings(library(optparse)))

# Print the sessionInfo so that there is a listing of loaded packages, 
# the current version of R, and other environmental information in our
# stdout file. This can be useful for reproducibility, troubleshooting
# and comparing between runs.
sessionInfo()

# Get the command line arguments. We'll process these with optparse.
# https://cran.r-project.org/web/packages/optparse/index.html
arguments <- commandArgs(trailingOnly=TRUE)

# Declare an option list for optparse to use in parsing the command line.
option_list <- list(
    make_option("--data.file", dest="data.file"),
    make_option("--output.file", dest="output.file"),
    make_option("--num.patterns", type="integer", dest="num.patterns"),
    make_option("--num.iterations", type="integer", dest="num.iterations", default=50000),
    make_option("--param.file", dest="param.file", default=NULL),
    make_option("--transpose.data", type="logical", dest="transpose.data", default=FALSE),
    make_option("--num.threads", type="integer", dest="num.threads", default=1),
    make_option("--github.tag", dest="github.tag", default=NULL)
)

# Parse the command line arguments with the option list, printing the result
# to give a record as with sessionInfo.
opt <- parse_args(OptionParser(option_list=option_list),
    positional_arguments=TRUE, args=arguments)
print(opt)
opts <- opt$options

filename <- opts$data.file

if (!is.null(opts$github.tag)) {
    print(paste("Trying to load a new CoGAPS version from github", opts$github.tag))
    BiocManager::install("FertigLab/CoGAPS", ask=FALSE, ref=opts$github.tag)
}
print(packageVersion("CoGAPS"))
cat(CoGAPS::buildReport())
suppressMessages(suppressWarnings(library(CoGAPS)))

if (!is.null(opts$param.file)) {
    params <- readRDS(opts$param.file)
} else {
    params <- CogapsParams()
}
print(paste("Filename is ", filename))
if (endsWith(tolower(filename), ".robj")){
    suppressMessages(suppressWarnings(library(Seurat)))
    suppressMessages(suppressWarnings(library(Matrix)))

    # assumes just one object in the file 
    env = new.env()
    matName <- load(filename, env, verbose=TRUE)[1]	
    mat <- env[[matName]]
    print("B")
    
    datMat2<-log2(as.matrix(GetAssayData(mat,assay="RNA",slot="counts"))+1)
    sparse.mat <- Matrix(datMat2, sparse = T)
    writeMM(obj = sparse.mat, file="./mat.mtx")
    geneNames<-rownames(sparse.mat)
    cellNames<-colnames(sparse.mat)
    params <- setParam(params, "geneNames", geneNames)
    params <- setParam(params, "sampleNames", cellNames)
    filename = "./mat.mtx"
}

params <- setParam(params, "nPatterns", opts$num.patterns)
params <- setParam(params, "nIterations", opts$num.iterations)

if (!is.null(params@distributed))
    opts$num.threads <- 1

gapsResult <- CoGAPS(data=filename, params=params,
    nThreads=opts$num.threads, transposeData=opts$transpose.data)
print(gapsResult)
saveRDS(gapsResult, file=paste(opts$output.file, "rds", sep="."))

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
# Note the use of suppressMessages and suppressWarnings here.  The package
# loading process is often noisy on stderr, which will (by default) cause
# GenePattern to flag the job as failing even when nothing went wrong. 
suppressMessages(suppressWarnings(library(getopt)))
suppressMessages(suppressWarnings(library(optparse)))
suppressMessages(suppressWarnings(library(CoGAPS)))

# Print the sessionInfo so that there is a listing of loaded packages, 
# the current version of R, and other environmental information in our
# stdout file.  This can be useful for reproducibility, troubleshooting
# and comparing between runs.
sessionInfo()

# Get the command line arguments.  We'll process these with optparse.
# https://cran.r-project.org/web/packages/optparse/index.html
arguments <- commandArgs(trailingOnly=TRUE)

print(packageVersion("CoGAPS"))
# Declare an option list for optparse to use in parsing the command line.
option_list <- list(
  # Note: it's not necessary for the names to match here, it's just a convention
  # to keep things consistent.
  make_option("--input.file", dest="input.file"),
  make_option("--transpose.data", type="logical", dest="transpose.data"),
  make_option("--pattern.start", type="integer", dest="pattern.start"),
  make_option("--pattern.stop", type="integer", dest="pattern.stop"),
  make_option("--pattern.step", type="integer", dest="pattern.step"),
  make_option("--num.iterations", type="integer", dest="num.iterations"),
  make_option("--seed", type="integer", dest="seed"),
  make_option("--single-cell", type="logical", default=FALSE, dest="single.cell"),
  make_option("--distributed.method", dest="distributed.method"), # should be either "none", "genome-wide", "single-cell"
  make_option("--num.sets", type="integer", dest="num.sets"),
  make_option("--num.threads", type="integer", dest="num.threads"),
  make_option("--stddev.input.file", dest="stddev.input.file"),
  make_option("--output.file", dest="output.file")
)

# Parse the command line arguments with the option list, printing the result
# to give a record as with sessionInfo.
opt <- parse_args(OptionParser(option_list=option_list), positional_arguments=TRUE, args=arguments)
print(opt)
opts <- opt$options
# Load some common GP utility code for handling GCT files and so on.  This is included
# with the module and so it will be found in the same location as this script (libdir).
source(file.path("/usr/local/bin/cogaps/", "common.R"))
#source(file.path("/usr/local/bin/cogaps/", "override_plotP.R"))
print(packageVersion("CoGAPS"))

# Process the parameters.  
# Note that since some parameters are optional, we must be prepared to receive no value
# Also check for blank values since these are ignored.
if (is.null(opts$stddev.input.file) || grepl("^[[:space:]]*$", opts$stddev.input.file)) {
   stddev_input <- NULL
} else {
    if (!file.exists(opts$stddev.input.file)) {
        stop("StdDev GCT file does not exist")
    }
    stddev_gct <- read.gct(opts$stddev.input.file)
    stddev_input <- as.matrix(stddev_gct[["data"]])
    #stddev_input <- opts$stddev.input.file
}

# Optparse will validate increment.value and convert it to a numeric value or give it the
# default value of 10 if missing.  We must check for NA however (and NULL, to be safe) as
# it will use that for non-numeric values.

# Create the CogapsParams object - read the parameters into this
params <- new("CogapsParams")

# parse nIterations
if (is.null(opts$num.iterations) || is.na(opts$num.iterations)) {
   stop("Parameter num.iterations must be numeric")
}
params <- setParam(params, "nIterations", opts$num.iterations)

# parse seed
if (is.null(opts$seed) || is.na(opts$seed)) {
   stop("Parameter seed must be numeric")
}
params <- setParam(params, "seed", opts$seed)

# parse singleCell
if (is.null(opts$single.cell) || is.na(opts$single.cell)) {
   stop("Parameter single.cell must be logical")
}
params <- setParam(params, "singleCell", opts$single.cell)

# parse distributed
if (is.null(opts$distributed.method) || is.na(opts$distributed.method) || !(opts$distributed.method %in% c("none", "genome-wide", "single-cell"))) {
    stop("distributed.method must be either none, genome-wide, or single-cell")
}
if (opts$distributed.method != "none") {
  params <- setParam(params, "distributed", opts$distributed.method)
}

# parse nSets
if (is.null(opts$num.sets) || is.na(opts$num.sets)) {
   stop("Parameter num.sets must be numeric")
}
params <- setDistributedParams(params, nSets=opts$num.sets)

# these arguments are passed directly
if (is.null(opts$transpose.data) || is.na(opts$transpose.data)) {
   stop("Parameter transpose.data must be logial")
}
if (is.null(opts$num.threads) || is.na(opts$num.threads)) {
   stop("Parameter num.threads must be numeric")
}

# create pattern range
#prange <- paste("seq(", opts$pattern.start, ", ", opts$pattern.stop, ", by=", opts$pattern.step, ")", sep="")
#patternRange <- eval(parse(text=prange))
if (is.null(opts$pattern.start) || is.na(opts$pattern.start)) {
    stop("Parameter pattern.start must be numeric")
}
if (is.null(opts$pattern.stop) || is.na(opts$pattern.stop)) {
    stop("Parameter pattern.stop must be numeric")
}
if (is.null(opts$pattern.step) || is.na(opts$pattern.step)) {
    stop("Parameter pattern.step must be numeric")
}
patternRange <- seq(opts$pattern.start, opts$pattern.stop, opts$pattern.step)

# Load the GCT input file.
print("Loading gct file now")
if (!file.exists(opts$input.file)) {
    stop("GCT file does not exist")
}
gct <- read.gct(opts$input.file)
data_input <- as.matrix(gct[["data"]])
# data_input <- opts$input.file

# loop over patternRange
files2zip = {} 
cogapsResult <- list()
for (nPatterns in patternRange)
{
    cogapsResult[[nPatterns]] <- CoGAPS(data=data_input, params=params,
        nPatterns=nPatterns, transposeData=opts$transpose.data,
        nThreads=opts$num.threads, uncertainty=stddev_input)
  
    currentResult <- cogapsResult[[nPatterns]]
    
    # don't use sub directories until the GPNB can handle them properly
    # dirName = paste("n_", nPatterns, sep="")
    # dir.create(dirName)
    dirName="."

    pdf(file.path(dirName, paste(opts$output.file,"_", nPatterns, ".pdf", sep="")))
    plot(currentResult)
    dev.off()
   
    gctA <-list(data=currentResult@featureLoadings)
    write.gct(gctA, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Amean.gct", sep="")))
    gctAsd <-list(data=currentResult@featureStdDev)
    write.gct(gctAsd, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Asd.gct", sep="")))
    gctP <-list(data=currentResult@sampleFactors)
    write.gct(gctP, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Pmean.gct", sep="")))
    gctPsd <-list(data=currentResult@sampleStdDev)
    write.gct(gctPsd, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Psd.gct", sep="")))
    files2zip = c(files2zip,dir(dirName, full.names = TRUE)) 
}
chisq <- sapply(patternRange, function(i) getMeanChiSq(cogapsResult[[i]]))
chiPdfFilename = paste(opts$output.file, "_chiSquare.pdf", sep="")
pdf(chiPdfFilename)
plot(patternRange, chisq)
dev.off()

chiFilename=paste(opts$output.file, "_chiSquare.tsv", sep="")
xx = cbind(patternRange, chisq)
colnames(xx) = c("num.patterns", "chisq")
write.table(xx, file=chiFilename, row.names=TRUE, col.names=TRUE)

files2zip = c(files2zip, chiPdfFilename, chiFilename)
zipFileName=paste(opts$output.file, ".zip", sep="")
zip(zipfile=zipFileName, files=files2zip)




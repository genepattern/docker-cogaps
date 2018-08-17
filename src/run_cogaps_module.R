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
  make_option("--num.iterations", type="integer", dest="num.iterations"),
  make_option("--seed", type="integer", dest="seed"),
  make_option("--distributed.method", dest="distributed.method"), # should be either NULL, "genome-wide", "single-cell"
  make_option("--num.sets", type="integer", dest="num.sets"),
  make_option("--input.file", dest="input.file"),
  make_option("--stddev.input.file", dest="stddev.input.file"),
  #make_option("--stddev.decimal.value", type="double", dest="stddev.decimal.value"),
  make_option("--pattern.start", type="integer", dest="pattern.start"),
  make_option("--pattern.stop", type="integer", dest="pattern.stop"),
  make_option("--pattern.step", type="integer", dest="pattern.step"),
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
   stddev.input.file <- NULL
} else {
   stddev.input.file <- opts$stddev.input.file
}

# Optparse will validate increment.value and convert it to a numeric value or give it the
# default value of 10 if missing.  We must check for NA however (and NULL, to be safe) as
# it will use that for non-numeric values.
if (is.null(opts$num.iterations) || is.na(opts$num.iterations)) {
   stop("Parameter num.iterations must be numeric")
} else {
   num.iterations <- strtoi(opts$num.iterations)
}

if (is.null(opts$num.sets) || is.na(opts$num.sets)) {
   stop("Parameter num.sets must be numeric")
} else {
   num.sets <- strtoi(opts$num.sets)
}

if (is.null(opts$seed) || is.na(opts$seed)) {
   stop("Parameter seed must be numeric")
} else {
   seed <- opts$seed
}

prange <- paste("seq(", opts$pattern.start, ", ", opts$pattern.stop, ", by=", opts$pattern.step, ")", sep="")
patternRange <- eval(parse(text=prange))

# Load the GCT input file.
print("Loading gct file now")
if (!file.exists(opts$input.file)){
     print("GCT file does not exist")
}

# R object that manage CoGAPS parameters
params <- new("CogapsParams")
params <- setParam(params, "nIterations", num.iterations)
params <- setParam(params, "seed", seed)
params <- setParam(params, "seed", opts$distributed.method)
params <- setDistributedParams(params, num.sets)

files2zip = {} 
cogapsResult <- list()
for (nPatterns in patternRange)
{
    cogapsResult[[nPatterns]] <- CoGAPS(data=opts$input.file,
        params=params, uncertainty=stddev.input.file)
  
    currentResult <- cogapsResult[[nPatterns]]
    
    # don't use sub directories until the GPNB can handle them properly
    # dirName = paste("n_", nPatterns, sep="")
    # dir.create(dirName)
    dirName="."



    pdf(file.path(dirName, paste(opts$output.file,"_", nPatterns, ".pdf", sep="")))
    plot(currentResult)
    dev.off()
   
    gctA <-list(data=currentResult$featureLoadings)
    write.gct(gctA, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Amean.gct", sep="")))
    gctAsd <-list(data=currentResult$featureStdDev)
    write.gct(gctAsd, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Asd.gct", sep="")))
    gctP <-list(data=currentResult$sampleFactors)
    write.gct(gctP, file.path(dirName, paste(opts$output.file,"_", nPatterns, "_Pmean.gct", sep="")))
    gctPsd <-list(data=currentResult$sampleStdDev)
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




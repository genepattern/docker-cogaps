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
print(packageVersion("CoGAPS"))

# Get the command line arguments.  We'll process these with optparse.
# https://cran.r-project.org/web/packages/optparse/index.html
arguments <- commandArgs(trailingOnly=TRUE)

# Declare an option list for optparse to use in parsing the command line.
option_list <- list(
  # Note: it's not necessary for the names to match here, it's just a convention
  # to keep things consistent.
  make_option("--num.iterations", type="integer", dest="num.iterations"),
  make_option("--seed", type="integer", dest="seed"),
  make_option("--input.file", dest="input.file"),
  make_option("--stddev.input.file", dest="stddev.input.file"),
  make_option("--stddev.decimal.value", type="double", dest="stddev.decimal.value"),
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
source(file.path("/usr/local/bin/cogaps/", "override_plotP.R"))

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
if (is.null(opts$seed) || is.na(opts$seed)) {
   stop("Parameter seed must be numeric")
} else {
   seed <- opts$seed
}

prange <- paste("seq(", opts$pattern.start, ", ", opts$pattern.stop, ", by=", opts$pattern.step, ")", sep="")
patternRange <- eval(parse(text=prange))

# Due to the choices presented in the manifest, GP will *only* allow the strings "true" and "false" 
# here, so there's no need to convert it to a logical value; optparse will take care of that for us.

# Load the GCT input file.
print("Loading gct file now")
if (!file.exists(opts$input.file)){
     print("GCT file does not exist")
}
gct <- read.gct(opts$input.file)

min(gct[['data']])
# XXX TEMP TO USE THIS FOR TESTING WITH ALL AML THAT HAS NEGATIVE VALUES
gct[['data']] <- gct[['data']] + abs(min(gct[['data']]) ) +1

min(gct[['data']])


if (is.null(opts$stddev.input.file)){
    stddev <- abs(gct[['data']] * 0.1) + 1
} else {
    print("Trying to read std deviation input file")
    # assume stddev is 10% of the expression values and prevent it from being 0 	
    stddev <- read.gct(opts$stddev.input.file)
    stddev <- stddev[['data']]

}

class(num.iterations)

#results <- gapsRun(gct[['data']], stddev, nFactor=3, nEquil=num.iterations, nSample=num.iterations)
#plotGAPS(results$Amean, results$Pmean, 'ModSimFigs')
cogapsResult <- list()
for (nPatterns in patternRange)
{
    cogapsResult[[nPatterns]] <- CoGAPS(as.matrix(gct[["data"]]),
        as.matrix(stddev), nFactor=nPatterns, nSample=num.iterations,
        nEquil=num.iterations)
}
chisq <- sapply(patternRange, function(i) cogapsResult[[i]]$meanChi2)
pdf(paste(opts$output.file, "_chiSquare.pdf", sep=""))
plot(patternRange, chisq)
dev.off()

bestPattern <- which.min(chisq)
bestResult <- cogapsResult[[patternRange[[bestPattern]]]]
pdf(paste(opts$output.file, ".pdf", sep="")) 
#pdf("output.pdf")

override_plotP(bestResult$Pmean)
dev.off()

#
#  CoGAPS example from docs
#
#results2 <- CoGAPS(data=SimpSim.D, unc=SimpSim.S, GStoGenes=GSets, nFactor=3, nEquil=nIter, nSample=nIter, plot=TRUE)
#
#plotGAPS(results2$Amean, results2$Pmean, 'GSFigs')
#

# Print the sessionInfo once more on the way out.  This is not strictly necessary
# but gives us another snapshot of the environment in final form as another point
# for troubleshooting in case anything has changed.
sessionInfo()

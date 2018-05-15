## try http:// if https:// URLs are not supported
source("https://bioconductor.org/biocLite.R")
biocLite("CoGAPS", ask=FALSE)
install.packages(c("optparse", "parallel", "foreach", "doParallel"))

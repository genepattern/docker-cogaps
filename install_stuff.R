## try http:// if https:// URLs are not supported
# module specific packages first 

source("http://bioconductor.org/biocLite.R")
install.packages(c("optparse", "parallel", "foreach", "doParallel"))

# install dependencies hosted on CRAN
cran_packages <- c("Rcpp", "RColorBrewer", "gplots", "cluster", "shiny", 
    "doParallel", "foreach", "ggplot2", "reshape", "testthat", "lintr", "knitr",
    "rmarkdown", "BH")

install.packages(cran_packages, repos='http://cran.us.r-project.org')

# install dependencies hosted on BiocConductor
bioc_packages <- c("BiocStyle")
biocLite()
biocLite(bioc_packages)




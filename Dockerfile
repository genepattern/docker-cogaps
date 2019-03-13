# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.

FROM r-base:3.5.1

RUN mkdir /build

# apt-get install -t unstable libmariadbclient-dev  --yes && \

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install -t unstable libssl-dev  --yes && \
    apt-get install libxml2-dev --yes && \
    apt-get install libssl-dev -y && \
    apt-get install libcurl4-gnutls-dev --yes && \
    apt-get install mesa-common-dev --yes && \ 
    apt-get update && apt-get install -y --no-install-recommends apt-utils && \
    apt-get install aptitude -y && \
    apt-get install libxml2-dev -y && \
    aptitude install libglib2.0-dev -y && \
    apt-get install libcairo2-dev -y && \
    aptitude install libpango-1.0-0 -y && \
    aptitude install libpangocairo-1.0-0 -y && \
    aptitude install libpangoft2-1.0-0 -y   && \
    apt-get install xvfb -y && \
    apt-get install xauth xfonts-base libxt-dev -y && \
    rm -rf /var/lib/apt/lists/*

# apt-get install libpango1.0 libgtk2.0  -y && \

COPY sources.list /etc/apt/sources.list
COPY Rprofile.gp.site ~/.Rprofile
COPY Rprofile.gp.site /usr/lib/R/etc/Rprofile.site
ENV R_LIBS_S3=/genepattern-server/Rlibraries/R344/rlibs
ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_HOME=/usr/local/lib64/R

# install R dependencies
RUN R -e 'install.packages("remotes")'
RUN R -e 'install.packages("BiocManager")'
RUN R -e 'BiocManager::install("BiocParallel")'
RUN R -e 'BiocManager::install("cluster")'
RUN R -e 'BiocManager::install("data.table")'
RUN R -e 'BiocManager::install("methods")'
RUN R -e 'BiocManager::install("gplots")'
RUN R -e 'BiocManager::install("graphics")'
RUN R -e 'BiocManager::install("grDevices")'
RUN R -e 'BiocManager::install("RColorBrewer")'
RUN R -e 'BiocManager::install("Rcpp")'
RUN R -e 'BiocManager::install("S4Vectors")'
RUN R -e 'BiocManager::install("stats")'
RUN R -e 'BiocManager::install("tools")'
RUN R -e 'BiocManager::install("utils")'
RUN R -e 'BiocManager::install("rhdf5")'
RUN R -e 'BiocManager::install("testthat")'
RUN R -e 'BiocManager::install("knitr")'
RUN R -e 'BiocManager::install("rmarkdown")'
RUN R -e 'BiocManager::install("BiocStyle")'
RUN R -e 'BiocManager::install("Rcpp")'
RUN R -e 'BiocManager::install("SummarizedExperiment")'
RUN R -e 'BiocManager::install("SingleCellExperiment")'
RUN R -e 'BiocManager::install("optparse")'

# install latest version of CoGAPS from github
RUN echo "force rebuild 4" && \
    R -e 'BiocManager::install("FertigLab/CoGAPS", dependencies=FALSE)' && \
    R -e 'packageVersion("CoGAPS")'

# the module files are set into /usr/local/bin/cogaps
ENV PATH "$PATH:/usr/local/bin/cogaps"
COPY src/* /usr/local/bin/cogaps/
 
CMD ["Rscript", "/usr/local/bin/cogaps/run_cogaps_module.R" ]


# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.

FROM r-base:3.5.1

RUN mkdir /build

# apt-get install -t unstable libmariadbclient-dev  --yes && \

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install -t unstable libssl-dev  --yes && \
    apt-get install libxml2-dev --yes && \
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
COPY install_stuff.R /build/source/install_stuff.R

RUN Rscript /build/source/install_stuff.R

RUN apt-get update -y && \
    apt-get install -y  -t unstable git && \
    apt install -t unstable -y  libomp-dev && \
    mkdir /cogaps_src &&\
    cd /cogaps_src && \
    git clone https://github.com/FertigLab/CoGAPS.git && \
    cd CoGAPS && \
    echo "layer change to forece rebuild" && \
    git checkout develop && \
    R CMD build --no-build-vignettes /cogaps_src/CoGAPS && \
    R CMD INSTALL CoGAPS_*.tar.gz && \
    rm -rf /cogaps_src && \
    rm -rf /var/lib/apt/lists/*

# git checkout master && \
#     git checkout 40c26bed3b62ba4cfaa5aeaf2f265763ee82bfe4 && \


# the module files are set into /usr/local/bin/cogaps
ENV PATH "$PATH:/usr/local/bin/cogaps"
COPY src/* /usr/local/bin/cogaps/
 
CMD ["Rscript", "/usr/local/bin/cogaps/run_gp_tutorial_module.R" ]


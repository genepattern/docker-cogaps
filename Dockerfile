# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.

FROM r-base:3.4.3

RUN mkdir /build

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install build-essential --yes && \
    apt-get install python --yes && \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py 

RUN pip install awscli 

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install -t unstable libmariadbclient-dev  --yes && \
    apt-get install -t unstable libssl-dev  --yes && \
    apt-get install curl --yes 

RUN    apt-get install libxml2-dev --yes && \
    apt-get install libcurl4-gnutls-dev --yes && \
    apt-get install mesa-common-dev --yes 

# Update cache and install apt-utils for aptitude
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get install aptitude -y
RUN apt-get install libxml2-dev -y

# Cairo required
#RUN aptitude install libglib2.0-0=2.54.1-1 -y
RUN aptitude install libglib2.0-dev -y
RUN apt-get install libcairo2-dev -y

RUN aptitude install libpango-1.0-0 -y
RUN aptitude install libpangocairo-1.0-0 -y
RUN aptitude install libpangoft2-1.0-0 -y
RUN apt-get install libpango1.0-dev libgtk2.0-dev xvfb xauth xfonts-base libxt-dev -y



COPY common/container_scripts/runS3OnBatch.sh /usr/local/bin/runS3OnBatch.sh
COPY common/container_scripts/installPackages.R-2  /build/source/installPackages.R
COPY sources.list /etc/apt/sources.list
COPY common/container_scripts/runLocal.sh /usr/local/bin/runLocal.sh
COPY Rprofile.gp.site ~/.Rprofile
COPY Rprofile.gp.site /usr/lib/R/etc/Rprofile.site
RUN chmod ugo+x /usr/local/bin/runS3OnBatch.sh
ENV R_LIBS_S3=/genepattern-server/Rlibraries/R344/rlibs
ENV R_LIBS=/usr/local/lib/R/site-library
ENV R_HOME=/usr/local/lib64/R
COPY install_stuff.R /build/source

RUN Rscript /build/source/install_stuff.R
RUN apt-get update -y && \
    apt-get install -y  -t unstable git

RUN apt install -t unstable -y  libomp-dev

RUN mkdir /cogaps_src &&\
    cd /cogaps_src && \
    git clone https://github.com/FertigLab/CoGAPS.git && \
    cd CoGAPS && \
    git checkout --track origin/develop


RUN R CMD build --no-build-vignettes /cogaps_src/CoGAPS && \
   R CMD INSTALL CoGAPS_*.tar.gz


# the module files are set into /usr/local/bin/cogaps
ENV PATH "$PATH:/usr/local/bin/cogaps"
COPY src/* /usr/local/bin/cogaps/
 
CMD ["Rscript", "/usr/local/bin/cogaps/run_gp_tutorial_module.R" ]


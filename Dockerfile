FROM ubuntu:16.04

MAINTAINER PhenoMeNal-H2020 Project (phenomenal-h2020-users@googlegroups.com)

LABEL software="OpenMS2XCMS"
LABEL software.version="1.53.1"
LABEL version="0.2"
LABEL Description="Convert OpenMS to XCMS"
LABEL website="https://github.com/sneumann/xcms"
LABEL documentation="https://github.com/phnmnl/container-xcms/blob/master/README.md"
LABEL license="https://github.com/phnmnl/container-midcor/blob/master/License.txt"
LABEL tags="Metabolomics"

# Add cran R backport
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y install apt-transport-https perl locales
RUN echo "deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Generate locales
ENV LC_ALL="en_US.UTF-8"
ENV LC_CTYPE="en_US.UTF-8"
RUN locale-gen $LC_ALL
RUN dpkg-reconfigure locales

# Install packages
RUN apt-get -y update && apt-get -y dist-upgrade && apt-get -y --allow-unauthenticated install apt-transport-https make gcc gfortran g++ libblas-dev liblapack-dev libxml++2.6-dev libexpat1-dev libxml2-dev libnetcdf-dev libssl-dev r-base r-base-dev maven texlive-latex-base texlive-latex-recommended texlive-fonts-recommended git openjdk-8-jdk-headless openjdk-8-jre-headless pkg-config parallel wget curl git unzip zip python3 make gcc gfortran g++ libnetcdf-dev libxml2-dev libblas-dev liblapack-dev libssl-dev pkg-config git python3 python3-pip libqtgui4 python3-setuptools

# Install R packages
RUN R -e 'install.packages(c("irlba","igraph","ggplot2","digest","lattice","XML","Rcpp","reshape2","plyr","stringi","stringr","intervals","devtools","RColorBrewer","plyr","RANN","knitr","ncdf4","microbenchmark","RUnit","foreach","doMC","curl","jsonlite"), repos="https://cloud.r-project.org/")'

# Install  Bioconductor 
RUN R -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager"); BiocManager::install(c("multtest","MSnbase","mzR","MassSpecWavelet","S4Vectors","BiocStyle","faahKO","msdata","xcms","CAMERA","lattice","RColorBrewer","plyr","RANN","multtest","knitr","ncdf4","microbenchmark","RUnit","devtools","ncdf4"), ask=FALSE)'

#    R -e 'library(devtools); install_github(repo="sneumann/xcms", ref="d9baa6ca364f4dd197a9eedd361869cf0787dbc3")' && \
#    R -e 'library(devtools); install_github(repo="sneumann/CAMERA", ref="cbc9cdb2eba6438434c27fec5fa13c9e6fdda785")' && \

# Install pyopenms
RUN pip3 install -Iv pyopenms==2.1.0 numpy

# Add scripts to container
ADD scripts/*.r /usr/local/bin/
RUN chmod +x /usr/local/bin/*.r

# Cleanup
RUN apt-get -y --purge --auto-remove remove make gcc gfortran g++
RUN apt-get -y clean && apt-get -y autoremove && rm -rf /var/lib/{cache,log}/ /tmp/* /var/tmp/*

# Add testing to container
# ADD runTest1.sh /usr/local/bin/runTest1.sh

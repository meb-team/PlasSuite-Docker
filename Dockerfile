FROM debian:buster-slim
MAINTAINER Didier Debroas <didier.debroas@uca.fr>
# miniconda install based on https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 bioperl git mercurial subversion make && \
    apt-get clean

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

CMD [ "/bin/bash" ]



RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
# PlasFlow
RUN conda create --name plassuite python=3.5
RUN conda install  -n plassuite -c jjhelmus tensorflow=0.10.0rc0
RUN conda install -n plassuite plasflow -c smaegol
RUN conda install -n plassuite -c biobuilds perl=5.22
RUN conda install -n plassuite -c bioconda perl-bioperl perl-getopt-long

	# update Plasflow
RUN wget  https://github.com/smaegol/PlasFlow/archive/v1.1.tar.gz && \
	tar xf v1.1.tar.gz && \
	cp PlasFlow-1.1/* /opt/conda/envs/plassuite/bin/ -r

# PlasFlow end
RUN conda install -n plassuite -c bioconda cd-hit
RUN conda install -n plassuite -c bioconda samtools
RUN conda install -n plassuite -c bioconda bwa
RUN conda install -n plassuite -c etetoolkit ete3 ete_toolchain
RUN conda install -n plassuite  -c conda-forge -c bioconda -c defaults prokka
RUN conda install -n plassuite minimap2=2.14
RUN conda install -n plassuite blast=2.7


RUN wget ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn/linux64.tbl2asn.gz && \
    gunzip linux64.tbl2asn.gz && \
    mv linux64.tbl2asn tbl2asn && \
    chmod +x tbl2asn && \
    mv tbl2asn /opt/conda/envs/plassuite/bin/tbl2asn
    
# Environment R -> /opt/conda/envs/plassuite/bin/R
RUN /opt/conda/envs/plassuite/bin/Rscript -e 'install.packages("circlize", repos="http://cran.us.r-project.org")'
RUN /opt/conda/envs/plassuite/bin/Rscript -e 'install.packages("genoPlotR", repos="http://cran.us.r-project.org")'
RUN /opt/conda/envs/plassuite/bin/Rscript -e 'install.packages("ade4", repos="http://cran.us.r-project.org")'
RUN echo "conda activate plassuite" >> root/.bashrc

# PlasSuite installation without database
RUN git clone https://github.com/meb-team/PlasSuite.git
ENV PATH="/opt/conda/envs/plassuite/bin/:${PATH}"

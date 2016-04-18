#Pull base image
FROM ubuntu:14.04

# Run updates
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install wget -y

# Install dependencies
RUN apt-get install -y gcc libatlas-base-dev gfortran build-essential python-dev
RUN apt-get install -y libcairo2-dev libnetpbm10-dev netpbm python-virtualenv
RUN apt-get install -y libpng12-dev libjpeg-dev python-pyfits zlib1g-dev \
                       libbz2-dev swig libcfitsio3-dev
RUN apt-get install -y python-software-properties software-properties-common
RUN apt-get install -y libhdf5-dev
RUN apt-get install -y python-setuptools 
RUN apt-get install -y python-scipy
RUN apt-get install -y python-numpy

RUN virtualenv VIRTUAL
RUN VIRTUAL/bin/pip install --upgrade pip
RUN VIRTUAL/bin/pip install scipy
RUN VIRTUAL/bin/pip install numpy
RUN VIRTUAL/bin/pip install h5py
RUN VIRTUAL/bin/pip install pysam

# Update Boost
RUN wget 'http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz'
RUN tar zxf boost_1_60_0.tar.gz
RUN cd boost_1_60_0 && ./bootstrap.sh --prefix=/usr/local && ./b2 install

# Install pbcore
RUN apt-get install git -y
RUN git clone https://github.com/PacificBiosciences/pbcore.git
RUN VIRTUAL/bin/pip install -r pbcore/requirements.txt
RUN cd pbcore && ../VIRTUAL/bin/python setup.py install 

## Install ConsensusCore 
RUN cd /
RUN git clone https://github.com/PacificBiosciences/ConsensusCore.git
RUN cd /ConsensusCore && ../VIRTUAL/bin/python setup.py install --boost=/usr/local/include/

## Install ConsensusCore2
#RUN git clone https://github.com/PacificBiosciences/ConsensusCore2.git
#RUN apt-get install libboost-dev -y
#RUN cd /ConsensusCore2 && ../VIRTUAL/bin/python setup.py install --boost=/usr/local/include/

## Install GenomicConsensus (quiver)
RUN add-apt-repository ppa:george-edison55/cmake-3.x
RUN apt-get update
RUN apt-get install swig cmake -y
RUN cd /
RUN git clone https://github.com/PacificBiosciences/GenomicConsensus.git
RUN cd GenomicConsensus && ../VIRTUAL/bin/python setup.py install

ENV PATH /VIRTUAL/bin:$PATH
ENTRYPOINT ["quiver"]

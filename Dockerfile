# Set the base image
FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive

# File Author / Maintainer
MAINTAINER Jason Shi jason.shi@gladstone.ucsf.edu

# Add packages, update image, and clear cache
RUN apt-get update && apt-get install -y build-essential curl wget python-pip python-dev python-scipy python-redis gdebi-core zip unzip g++ zlib1g-dev gcc pkg-config apt-utils make perl cmake libbz2-dev

RUN pip install --upgrade pip
RUN pip install biopython pysam
RUN pip install htseq==0.6.1p1

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3.7

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2

WORKDIR /tmp
# install samtools
RUN apt-get install -y libncurses-dev libbz2-dev
RUN wget https://github.com/samtools/samtools/releases/download/1.5/samtools-1.5.tar.bz2
RUN tar -jxf samtools-1.5.tar.bz2
WORKDIR /tmp/samtools-1.5
RUN ./configure --disable-lzma
RUN make -j 16
RUN mv samtools /usr/local/bin/

WORKDIR /tmp
# Compile and install cdhit-dup tools
RUN wget https://github.com/weizhongli/cdhit/archive/V4.6.8.zip
RUN unzip V4.6.8.zip
WORKDIR /tmp/cdhit-4.6.8
RUN make -j 16
WORKDIR /tmp/cdhit-4.6.8/cd-hit-auxtools
RUN make -j 16
RUN mv cd-hit-dup /usr/local/bin/

WORKDIR /tmp

# For aegea
RUN apt-get install -y python3-pip
RUN pip3 install awscli-cwlogs==1.4.0 keymaker==0.2.1 boto3==1.4.3 awscli==1.11.44 dynamoq==0.0.5 tractorbeam==0.1.3
RUN pip3 install pysam biopython
RUN apt-get update && apt-get install -y iptables-persistent debian-goodies bridge-utils pixz cryptsetup-bin mdadm btrfs-tools libffi-dev libssl-dev libxml2-dev libxslt1-dev libyaml-dev libcurl4-openssl-dev libjemalloc-dev libzip-dev libsnappy-dev liblz4-dev libgmp-dev libmpfr-dev libhts-dev libsqlite3-dev libncurses5-dev htop pydf jq httpie python-dev python-cffi python-pip python-setuptools python-wheel python-virtualenv python-requests python-yaml python3-dev python3-cffi python3-pip python3-setuptools python3-wheel python3-requests python3-yaml nfs-common unzip build-essential cmake libtool autoconf ruby sysstat dstat numactl gdebi-core sqlite3 stunnel moreutils curl wget git aria2 sift
# Strange that we have to do this, but if we don't, aegea tries to do it, and it fails then with some urllib3 bug.
RUN apt-get -y install awscli

RUN apt-get install -y bsdtar alien

# For de-novo assembly
WORKDIR /tmp/spades_build
RUN git clone https://github.com/ablab/spades.git
WORKDIR /tmp/spades_build/spades
RUN git checkout spades_3.11.0
WORKDIR /tmp/spades_build/spades/assembler
RUN PREFIX=/usr/local ./spades_compile.sh
RUN /usr/local/bin/spades.py --test

# For nonhost fastq filtering
WORKDIR /tmp/seqtk_build
RUN git clone https://github.com/lh3/seqtk.git
WORKDIR /tmp/seqtk_build/seqtk
RUN make && make install

WORKDIR /tmp

# Blast command line
RUN wget -N ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.6.0/ncbi-blast-2.6.0+-1.x86_64.rpm
RUN alien -i ncbi-blast-2.6.0+-1.x86_64.rpm
RUN rm -rf ncbi-blast-2.6.0+-1.x86_64.rpm

# For adapter trimming
RUN apt install python-cutadapt
WORKDIR /tmp
RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip
RUN unzip Trimmomatic-0.38.zip
RUN mv Trimmomatic-0.38/trimmomatic-0.38.jar /usr/local/bin/
RUN apt-get update && apt-get install -y default-jre

RUN apt-get -y install liblz4-tool
RUN apt-get -y install lbzip2

# Cleanup
RUN rm -rf /tmp/*

WORKDIR /

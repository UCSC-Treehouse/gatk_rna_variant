FROM ubuntu:14.04
MAINTAINER linh lam

RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
  wget \
  unzip \
  software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa -y
RUN apt-get update && apt-get install -y --force-yes --no-install-recommends \
  openjdk-8-jdk


WORKDIR /root
RUN wget https://github.com/broadinstitute/picard/releases/download/2.8.0/picard.jar
RUN wget http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip
RUN unzip snpEff_latest_core.zip
RUN java -jar ./snpEff/snpEff.jar download GRCh38.86
ADD ./GenomeAnalysisTK.jar /root
ADD ./run.sh /root
WORKDIR /data/work
ADD ./hglft_genome_24bb_d53250_variants.bed /root
ADD ./cc_genelist.bed /root 



ENTRYPOINT ["/root/run.sh"]



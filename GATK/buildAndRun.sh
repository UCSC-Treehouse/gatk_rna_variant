#!/bin/bash

docker build . -t rnaseq/linh

#docker run -it -v /data/ref:/data/ref -v /data/gatkRNA/input:/data/work rnaseq/linh

#docker run -it -v /data/ref:/data/ref -v /data/gatkRNA/input:/data/work -e input=TH05_0110_S01_RNASeq.sorted.bam rnaseq/linh | tee out


docker run -it -v /data/ref:/data/ref \
  -v /data/gatkRNA/input/test2:/data/work \
  -e refgenome=GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
  -e input=TH05_0110_S01_RNASeq.sorted.bam \
  -e variantlist=hglft_genome_24bb_d53250.bed \
  -e genelist=c.bed \
  rnaseq/linh | tee >>out


#docker run -v /data/ref:/data/ref -v /data/gatkRNA/input:/data/work rnaseq/linh

#docker run -it -v /data/ref:/data/ref -v /data/gatkRNA/input:/data/input rnaseq/linh | tee out 


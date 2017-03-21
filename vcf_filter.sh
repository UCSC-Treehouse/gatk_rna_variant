#!/bin/bash
set -eu -o pipefail


i=$input
r=$refgenome
tmpdir=" "
gl=$genelist 
vl=$variantlist

if [ ! -f "${i/.vcf}.vl.vcf.ok" ]; then
echo `date` "SelectVariants - variant list - $input">>/data/work/${i}.log;
java -Xmx20000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T SelectVariants \
  -R /data/ref/$refgenome \
  -V /data/work/${i}  \
  -o /data/work/${i/.vcf}.vl.vcf   \
  -L /data/ref/$vl;
echo `date` "SelectVariants - variant list - $input - Done">>/data/work/${i}.log;
>${i/.vcf}.vl.vcf.ok;
fi

if [ ! -f "${i/.vcf}.cg.vcf.ok" ]; then
echo `date` "SelectVariants - gene list - $input ">>/data/work/${i}.log;
java -Xmx50000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T SelectVariants \
  -R /data/ref/$refgenome \
  -V /data/work/${i}  \
  -o /data/work/${i/.vcf}.cg.vcf \
  -L /data/ref/$gl;
echo `date` "SelectVariants - gene list - $input - Done ">>/data/work/${i}.log;
>${i/.vcf}.cg.vcf.ok;
fi

#chown output files
finish() {
    # Fix ownership of output files
    uid=$(stat -c '%u:%g' /data/work)
    chown $uid ${i/.vcf}.cg.vcf 
    chown $uid ${i/.vcf}.cg.vcf.idx
    chown $uid ${i/.vcf}.vl.vcf
    chown $uid ${i/.vcf}.vl.vcf.idx
    chown $uid ${i}.log
}

trap finish EXIT


echo `date` "Done - $input">>/data/work/${i}.log;

rm ${i/.vcf}.vl.vcf.ok ${i/.vcf}.cg.vcf.ok 

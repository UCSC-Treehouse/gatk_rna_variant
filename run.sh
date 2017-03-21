#!/bin/bash
#v2 implemented  tempdir option. 

set -eu -o pipefail


i=$input
r=$refgenome
tmpdir=$tempdir
gl=cc_genelist.bed 
vl=hglft_genome_24bb_d53250_variants.bed

if [ ! -f "${i/.bam}.readgroups.bam.ok" ]; then
echo `date` "Add Read Groups - $input">>/data/work/${i/.bam}.log;
java -jar $tmpdir /root/picard.jar AddOrReplaceReadGroups I=/data/work/$i O=/data/work/${i/.bam}.readgroups.bam SORT_ORDER=coordinate RGLB=${i/.bam} RGPL=illumina RGPU=illumina RGSM=${i/.bam} VALIDATION_STRINGENCY=LENIENT  CREATE_INDEX=true ;
echo `date` "Add Read Groups - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.readgroups.bam.ok;
fi

if [ ! -f "${i/.bam}.split.bam.ok" ]; then
echo `date` "SplitNCigarReads - $input">>/data/work/${i/.bam}.log;
java -Xmx50000m -jar $tmpdir /root/GenomeAnalysisTK.jar -T SplitNCigarReads -R /data/ref/*.fa -I /data/work/${i/.bam}.readgroups.bam -o /data/work/${i/.bam}.split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS;
echo `date` "SplitNCigarReads - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.bam.ok;
fi

if [ ! -f "${i/.bam}.split.intervals.ok" ]; then
echo `date` "RealignerTargetCreator - $input">>/data/work/${i/.bam}.log;
java -Xmx5000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T RealignerTargetCreator \
  -R /data/ref/$r \
  -I /data/work/${i/.bam}.split.bam  \
  -o /data/work/${i/.bam}.split.intervals \
  -nt 24 ;
echo `date` "RealignerTargetCreator - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.intervals.ok;
fi

if [ ! -f "${i/.bam}.split.realigned.bam.ok" ]; then
echo `date` "IndelRealigner - $input">>/data/work/${i/.bam}.log;
java -Xmx50000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T IndelRealigner \
  -R /data/ref/$r \
  -I /data/work/${i/.bam}.split.bam  \
  -targetIntervals /data/work/${i/.bam}.split.intervals \
  -o /data/work/${i/.bam}.split.realigned.bam;
echo `date` "IndelRealigner - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.realigned.bam.ok;
fi

if [ ! -f "${i/.bam}.split.realigned.HaplotypeCaller.vcf.ok" ]; then
echo `date` "HaplotypeCaller - $input">>/data/work/${i/.bam}.log;
java -Xmx20000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T HaplotypeCaller \
  -R /data/ref/$r \
  -I /data/work/${i/.bam}.split.realigned.bam \
  -dontUseSoftClippedBases \
  -stand_call_conf 20.0 \
  -stand_emit_conf 20.0 \
  -o /data/work/${i/.bam}.split.realigned.HaplotypeCaller.vcf \
  -nct 4 ;
echo `date` "HaplotypeCaller - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.realigned.HaplotypeCaller.vcf.ok;
fi

if [ ! -f "${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf.ok" ]; then
echo `date` "VariantFiltration - $input">>/data/work/${i/.bam}.log;
java -Xmx20000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T VariantFiltration \
  -R /data/ref/$r \
  -V /data/work/${i/.bam}.split.realigned.HaplotypeCaller.vcf \
  -window 35 \
  -cluster 3 \
  -filterName FS \
  -filter "FS > 30.0" \
  -filterName QD \
  -filter "QD < 2.0" \
  -o /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf;
echo `date` "VariantFiltration - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf.ok;
fi

if [ ! -f "${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf.ok" ]; then
echo `date` "snpEff - $input">>/data/work/${i/.bam}.log;
java -Xmx10000m -jar $tmpdir /root/snpEff/snpEff.jar -v GRCh38.86 /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf > /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf;
rm snpEff_genes.txt;
rm snpEff_summary.html;
echo `date` "snpEff - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf.ok;
fi

if [ ! -f "${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf.ok" ]; then
echo `date` "SelectVariants - variant list - $input">>/data/work/${i/.bam}.log;
java -Xmx20000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T SelectVariants \
  -R /data/ref/$refgenome \
  -V /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf  \
  -o /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf    \
  -L /root/$vl;
echo `date` "SelectVariants - variant list - $input - Done">>/data/work/${i/.bam}.log;
>${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf.ok;
fi

if [ ! -f "${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf.ok" ]; then
echo `date` "SelectVariants - gene list - $input ">>/data/work/${i/.bam}.log;
java -Xmx50000m -jar $tmpdir /root/GenomeAnalysisTK.jar \
  -T SelectVariants \
  -R /data/ref/$refgenome \
  -V /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf  \
  -o /data/work/${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf \
  -L /root/$gl;
echo `date` "SelectVariants - gene list - $input - Done ">>/data/work/${i/.bam}.log;
>${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf.ok;
fi

#chown output files
finish() {
    # Fix ownership of output files
    uid=$(stat -c '%u:%g' /data/work)
    chown $uid ${i/.bam}.log
    chown $uid ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf
    chown $uid ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf.idx
    chown $uid ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf
    chown $uid ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf.idx
    chown $uid ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf
    chown $uid ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf.idx
    chown $uid ${i/.bam}.split.realigned.bai
    chown $uid ${i/.bam}.split.realigned.bam
}

trap finish EXIT


echo `date` "Done (linhvoyo/gatk_variant_v2) - $input">>/data/work/${i/.bam}.log;

rm ${i/.bam}.readgroups.bai ${i/.bam}.readgroups.bam ${i/.bam}.split.bai ${i/.bam}.split.bam ${i/.bam}.split.intervals ${i/.bam}.split.realigned.HaplotypeCaller.vcf ${i/.bam}.split.realigned.HaplotypeCaller.vcf.idx ${i/.bam}.readgroups.bam.ok ${i/.bam}.split.bam.ok ${i/.bam}.split.intervals.ok ${i/.bam}.split.realigned.bam.ok ${i/.bam}.split.realigned.HaplotypeCaller.vcf.ok ${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf.ok ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf.ok ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf.ok ${i/.bam}.split.realigned.HaplotypeCaller.filtered.ann.vcf.ok ${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf ${i/.bam}.split.realigned.HaplotypeCaller.filtered.vcf.idx 

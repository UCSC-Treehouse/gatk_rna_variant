#!/bin/bash

freeBayesSettings="--dont-left-align-indels --pooled-continuous --pooled-discrete -F 0.03 -C 2"

b=$1


echo here it is: $b


/root/freebayes/bin/freebayes --targets  /ref/TH_precise_merged.bed $freeBayesSettings -f /ref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa $b >  ${b/bam}mini.vcf

snpEffSettings="-nodownload -noNextProt -noMotif -noStats -classic -no PROTEIN_PROTEIN_INTERACTION_LOCUS -no PROTEIN_STRUCTURAL_INTERACTION_LOCUS"

java -Xmx10000m -jar /root/snpEff/snpEff.jar -v $snpEffSettings GRCh38.86 ${b/bam}mini.vcf >  ${b/bam}mini.ann.vcf

rm ${b/bam}mini.vcf

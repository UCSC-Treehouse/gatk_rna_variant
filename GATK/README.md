# GATK RNAseq Variant Calling Analysis
Docker image of GATK best practices approach for variant calling on RNAseq data. 

For full details please visit https://software.broadinstitute.org/gatk/guide/article?id=3891. 

The steps for the workflow are:
* Add read groups, sort, mark duplicates, and create index using PICARD (https://broadinstitute.github.io/picard/)
* Split’N’Trim and reassign mapping qualities
* GATK IndelRealigner
* snpEff (http://snpeff.sourceforge.net/SnpEff.html) 5) GATK HaplotypeCaller
* GATK SelectVariants

## Usage
    docker pull linhvoyo/gatk_rna_variant_v2
    
    docker run -it -v /path/to/ref_folder:/data/ref \ -v /path/to/input_folder/:/data/work \
        -e refgenome=input_reference_genome.fa \
        -e input=sample.sorted.bam \
        linhvoyo/gatk_rna_variant_v2 | tee >>/path/to/input_folder/out

## Details
    docker run 
Command to initiate docker.

    -v /path/to/ref folder:/data/ref
State the full path of directory containing the reference genome. The -v parameter will mount the listed directory into the docker container. 

    -v /path/to/input folder/:.data/work
State the full path of working directory containing the input bam file. 
    
    -e refgenome=input reference genome.fa
Provide the name of reference genome. 
    
    -e input=sample.sorted.bam
Provide the name of the input file. The docker takes in a sorted bam file that was aligned using STAR aligner (https://github.com/alexdobin/STAR).

## Example run command and the expected output

### Run command
    docker run -it -v /data/ref:/data/ref \
        -v $(pwd):/data/work \
        -e refgenome=GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \ 
        -e input=test.bam \
        linhvoyo/gatk_rna_variant_v2 | tee >> test.bam.out

### Output files
All output files will be in the mounted directory containing test.bam.

    test.split.realigned.bam
    test.split.realigned.bai
    test.split.realigned.HaplotypeCaller.filtered.ann.vcf 
    test.split.realigned.HaplotypeCaller.filtered.ann.vcf.idx

Variant calls filtered by the list of canonical variants obtained from Max H. The coordinates were converted from hg19 to hg38 using     UCSC liftOver (https://genome.ucsc.edu/cgi-bin/hgLiftOver).

    test.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf
    test.split.realigned.HaplotypeCaller.filtered.ann.vl.vcf.idx

Variant calls filtered by cancer genes. The list of cancer genes was downloaded from Cancer Census (https://cancer.sanger.ac.uk).     The coordiantes are in hg38.

    test.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf
    test.split.realigned.HaplotypeCaller.filtered.ann.cg.vcf.idx

The generated ”log” shows a brief overview of the variant calling process. The file will show ”Done (linhvoy- o/gatk rna variant v2) - test.bam” once sample has finished processing.

    test.bam.log
    
### Example Output
    Wed Mar 15 17:06:18 UTC 2017 Add Read Groups - test.bam
    Wed Mar 15 17:06:27 UTC 2017 Add Read Groups - test.bam - Done
    Wed Mar 15 17:06:27 UTC 2017 SplitNCigarReads - test.bam
    Wed Mar 15 17:06:38 UTC 2017 SplitNCigarReads - test.bam - Done
    Wed Mar 15 17:06:38 UTC 2017 RealignerTargetCreator - test.bam
    Wed Mar 15 17:11:47 UTC 2017 RealignerTargetCreator - test.bam - Done Wed Mar 15 17:11:47 UTC 2017 IndelRealigner - test.bam
    Wed Mar 15 17:12:01 UTC 2017 IndelRealigner - test.bam - Done
    Wed Mar 15 17:12:01 UTC 2017 HaplotypeCaller -
    Wed Mar 15 17:47:56 UTC 2017 HaplotypeCaller -
    Wed Mar 15 17:47:56 UTC 2017 VariantFiltration
    Wed Mar 15 17:48:00 UTC 2017 VariantFiltration
    Wed Mar 15 17:48:00 UTC 2017 snpEff - test.bam
    Wed Mar 15 17:49:34 UTC 2017 snpEff - test.bam
    Wed Mar 15 17:49:34 UTC 2017 SelectVariants - variant list - test.bam
    Wed Mar 15 17:49:38 UTC 2017 SelectVariants - variant list - test.bam - Done Wed Mar 15 17:49:38 UTC 2017 SelectVariants - gene list - test.bam
    Wed Mar 15 17:49:42 UTC 2017 SelectVariants - gene list - test.bam - Done Wed Mar 15 17:49:42 UTC 2017 Done (linhvoyo/gatk_rna_variant_v2) - test.bam

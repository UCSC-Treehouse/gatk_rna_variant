# RNA-Seq Variant Calling Analysis
Dockerized process for variant calling on RNA-Seq data. 

The steps for the workflow are:

- Call a small set of variants using Freebayes (v9.9.2-27-g5d5b8ac)
- Annotate variants using SnpEff (4.3r, GRCh38.86)

## Usage

```
docker run --rm -v /data/:/data \
hbeale/mini_var_call \
/data/sampleID.sortedByCoord.md.bam \
/data/ref/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa
```
## Availablity
The docker can be obtained from docker.io with the command.

```
 docker push hbeale/mini_var_call
```

The source code is available at 
https://github.com/UCSC-Treehouse/rna_variant_call.


## Notes
Because there are few of these variants, it is common to have no variants reported for a given sample. 

Because these are cannonical variants that may be supported by few reads, Freebayes is set to maximum sensitivity. Review stats and bam alignment to determine whether you think they are real. 

This type of error is expected and is not of concern:

```
Could not find any mapped reads in target region chr2:29222346..29222347
Could not find any mapped reads in target region chr2:29222406..29222407

```

## Input
The docker takes as arguments the locations of a coordinate-sorted bam and the  GCA_000001405.15_GRCh38_no_alt_analysis_set.fa. The fasta file must have a correponding index file. The bam file may have a corresponding index file (bai). It will greatly increase the speed (15 min -> 3 min for the file I tested time on), but indexing takes long enough that it doesn't doesn't improve the overall time required to index the bam file for this purpose alone. 

    
## Expected output file

The output file will be in the mounted directory containing test.bam.

    sampleID.mini.ann.vcf
    
The following commands can be used to review variants with a quality score above zero. We expect this to contain false positive variants, so review the full data if the preliminary results are of interest.

```
vcf=sampleID.sortedByCoord.md.mini.ann.vcf 
cat  $vcf | grep -v ^# | \
awk '$6 !~ /E/  && $6 > 0 { print }' | \
sed 's/^.*;EFF=\([^)]*\)).*/\1/' | \
cut -f6,4 -d"|" --output-delimiter " " | awk '{ print $2 " " $1}'
```

Generates this type of output: 

```
JAK2 R683S
NRAS G12D
```

## Example command line output (stdout)

```

00:00:00       SnpEff version SnpEff 4.3r (build 2017-09-06 16:41), by Pablo Cingolani
00:00:00       Command: 'ann'
00:00:00       Reading configuration file 'snpEff.config'. Genome: 'GRCh38.86'
00:00:00       Reading config file: /data/snpEff.config
00:00:00       Reading config file: /root/snpEff/snpEff.config
00:00:01       done
00:00:01       Reading database for genome version 'GRCh38.86' from file '/root/snpEff/./data/GRCh38.86/snpEffectPredictor.bin' (this might take a while)
00:00:35       done
00:00:35       Loading interactions from : /root/snpEff/./data/GRCh38.86/interactions.bin
00:00:52        Interactions: 1793688 added, 0 skipped.
00:00:52       Building interval forest
00:01:00       done.
00:01:00       Genome stats :
#-----------------------------------------------
# Genome name                : 'Homo_sapiens'
# Genome version             : 'GRCh38.86'
# Genome ID                  : 'GRCh38.86[0]'
# Has protein coding info    : true
# Has Tr. Support Level info : true
# Genes                      : 58051
# Protein coding genes       : 20423
#-----------------------------------------------
# Transcripts                : 198002
# Avg. transcripts per gene  : 3.41
# TSL transcripts            : 166906
#-----------------------------------------------
# Checked transcripts        : 
#               AA sequences :      0 ( 0.00% )
#              DNA sequences : 163038 ( 82.34% )
#-----------------------------------------------
# Protein coding transcripts : 94384
#              Length errors :  13357 ( 14.15% )
#  STOP codons in CDS errors :     51 ( 0.05% )
#         START codon errors :  11250 ( 11.92% )
#        STOP codon warnings :   7169 ( 7.60% )
#              UTR sequences :  91549 ( 46.24% )
#               Total Errors :  23099 ( 24.47% )
#-----------------------------------------------
# Cds                        : 704604
# Exons                      : 1182163
# Exons with sequence        : 1182163
# Exons without sequence     : 0
# Avg. exons per transcript  : 5.97
# WARNING!                   : Mitochondrion chromosome 'MT' does not have a mitochondrion codon table (codon table = 'Standard'). You should update the config file.
#-----------------------------------------------
# Number of chromosomes      : 524
# Chromosomes                : Format 'chromo_name size codon_table'
#              'HSCHR1_2_CTG3'  248975002       Standard
#              'HSCHR1_1_CTG31' 248973653       Standard
#              'HSCHR1_2_CTG31' 248971826       Standard


...
#              'KI270742.1'     186739  Standard
#              'GL000205.2'     185591  Standard
#              'GL000195.1'     182896  Standard
#              'KI270736.1'     181920  Standard
#              'KI270733.1'     179772  Standard
... and so on


00:01:08       done.
00:01:08       Logging
00:01:09       Checking for updates...
00:01:10       Done.
```


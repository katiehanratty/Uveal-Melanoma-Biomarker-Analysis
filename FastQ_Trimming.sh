#!/bin/bash

#TRIMMING FASTQ FILES
#set working directory to users fastq directory
#run cutadapt 
for i in *_1.fastq.gz; do
cutadapt -j=1 -a AGATCGGAAGAG -A AGATCGGAAGAG \  #change sequence as needed
--output=trimmed_$i --paired-output=trimmed_${i%_1.fastq.gz}_2.fastq.gz \
--error-rate=0.1 --times=1 --overlap=3 --action=trim --minimum-length=35 \
--pair-filter=any --quality-cutoff=20 \
$i ${i%_1.fastq.gz}_2.fastq.gz > trimmed_${i%_1.fastq.gz}_cutadapt.log
done

#move trimmed files to their own directory 
mkdir -p ~/trimmed_fastq/FastQC
mv trimmed*fastq.gz ~/trimmed_fastq

#run fastqc and multiqc on the trimmed files
fastqc ~/trimmed_fastq/*.fastq.gz 
multiqc ~/trimmed_fastq --outdir=~/trimmed_fastq/FastQC


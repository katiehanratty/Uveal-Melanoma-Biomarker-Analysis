#!/bin/sh

#make directory for alignment 
mkdir -p ~/alignment/bamfiles
mkdir -p ~/alignment/samfiles

#ALIGN FASTQ TO HG38 REFERENCE 

for i in *_R1.fastq.gz; do
bwa mem -t 8 ~/alignment/reference/hg38.fa $i \  #edit threads as needed
${i%_R1.fastq.gz}_R2.fastq.gz > ${i%_R1.fastq.gz}.sam

#SAM TO BAM, SORTING AND INDEXING BAM FILE

samtools view -b ${i%_R1.fastq.gz}.sam | samtools sort -o ${i%_R1.fastq.gz}_sorted.bam
samtools index ${i%_R1.fastq.gz}_sorted.bam
done 

#move files to bamfile directory
mv *.bam ~/alignment/bamfiles
mv *.sam ~/alignment/samfiles


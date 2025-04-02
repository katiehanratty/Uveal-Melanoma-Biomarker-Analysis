#!/bin/sh

#OBTAIN READ GROUP INFORMATION

#set working directory to directory with the fastq files
#save pathway for bamfiles in memory
ALIGNED=~/alignment/bamfiles   #edit for directory names as needed

for fastqname in *R1.fastq.gz; do #edit for filenames as needed
echo "fastq file: $fastqname"
subject=${fastqname%_R1.fastq.gz} 
echo "subject: $subject"
#extract header from fastq file for readgroup creation 
fastq_header1=`gunzip -c $fastqname | head -n1| awk '{print $1}'`
fastq_header2=`gunzip -c $fastqname | head -n1| awk '{print $2}'`

#extract each element from the fastq headers
#NOTE:Ensure fastq header in colon delimited format 
IFS=: read -a fields1 <<< "$fastq_header1"
run_id=`echo ${fields1[1]}`
flowcell_id=`echo ${fields1[2]}`
lane=`echo ${fields1[3]}`

IFS=: read -a fields2 <<< "$fastq_header2"
index=`echo ${fields2[3]}`

#print each element to the terminal 
echo "run id is $run_id, flowcell id is $flowcell_id, lane is $lane, index is $index"
#readgroup=@RG"\t"ID:${run_id}.${lane}.${index}_${subject}"\t"LB:Batch1.${subject}"\t"SM:${subject}"\t"PL:ILLUMINA"\t"PU:${flowcell_id}.${lane}.${index}_${subject}
#echo "readgroup is: $readgroup"
RGID=ID:${run_id}.${lane}.${index}_${subject} #edit for filenames as needed
RGLB=Batch1.${subject}
RGSM=${subject}
RGPL=ILLUMINA #edit for platform as needed
RGPU=${flowcell_id}.${lane}.${index}_${subject}
echo "RGID is: $RGID"
echo "RGLB is: $RGLB"
echo "RGSM is: $RGSM"
echo "RGPL is: $RGPL"
echo "RGPU is: $RGPU"
echo ""

#ADD READGROUP INFORMATION TO BAMFILES

echo "Adding read group information to ${fastqname%_R1.fastq.gz}.sorted.bam:"
date +"%c"
picard AddOrReplaceReadGroups \
I=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted.bam \  #edit for filenames as needed
O=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_RG.bam \
RGID=$RGID \
RGLB=$RGLB \
RGPL=$RGPL \
RGPU=$RGPU \
RGSM=$RGSM \
VALIDATION_STRINGENCY=LENIENT
date +"%c"
echo ""

#FILTERING BAM

#remove non-primary alignments and reads with MAPQ<10
echo "Removing non-primary alignments and ambiguous reads (MAPQ<10) from ${fastqname%_R1.fastq.gz}_sorted_RG.bam:"
date +"%c"
samtools view -b -F 2304 -q 10 \
${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_RG.bam > ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp.bam
date +"%c"
echo ""

#remove unmapped reads with MAPQ>0
echo "Removing unmapped reads with MAPQ>0 from ${fastqname%_R1.fastq.gz}_sorted_reads_RG.bam:"
date +"%c"
samtools view -b -F 4 \
${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp.bam > ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam
date +"%c"
echo ""
#remove duplicate reads
echo "Removing duplicates from filtered ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam:"
date +"%c"
picard MarkDuplicates INPUT=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam \
OUTPUT=${ALIGNED}/filtered_bam/${fastqname%_R1.fastq.gz}_sorted_filtered_nodup_RG.bam \
REMOVE_DUPLICATES=true \
METRICS_FILE=${ALIGNED}/metrics/${fastqname%_R1.fastq.gz}.filtered_nodup.metrics.txt \
VALIDATION_STRINGENCY=LENIENT
date +"%c"
echo ""

#move files into respective directories
mv ${fastqname%_R1.fastq.gz}_sorted.bam ${ALIGNED}/raw_files
mv ${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam ${ALIGNED}/intermediate_files
mv ${fastqname%_R1.fastq.gz}_sorted_RG.bam ${ALIGNED}/intermediate_files
mv ${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp.bam ${ALIGNED}/intermediate_files

done

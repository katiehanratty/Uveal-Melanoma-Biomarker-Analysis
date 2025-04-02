#!/bin/sh
ALIGNED=~/alignment/bamfiles

for fastqname in *R1.fastq.gz; do
echo "fastq file: $fastqname"
subject=${fastqname%_R1.fastq.gz} 
echo "subject: $subject"

fastq_header1=`gunzip -c $fastqname | head -n1| awk '{print $1}'`
fastq_header2=`gunzip -c $fastqname | head -n1| awk '{print $2}'`

IFS=: read -a fields1 <<< "$fastq_header1"
run_id=`echo ${fields1[1]}`
flowcell_id=`echo ${fields1[2]}`
lane=`echo ${fields1[3]}`

IFS=: read -a fields2 <<< "$fastq_header2"
index=`echo ${fields2[3]}`

echo "run id is $run_id, flowcell id is $flowcell_id, lane is $lane, index is $index"
#readgroup=@RG"\t"ID:${run_id}.${lane}.${index}_${subject}"\t"LB:Batch1.${subject}"\t"SM:${subject}"\t"PL:ILLUMINA"\t"PU:${flowcell_id}.${lane}.${index}_${subject}
#echo "readgroup is: $readgroup"
RGID=ID:${run_id}.${lane}.${index}_${subject} #################EDIT ACCORDING TO FILENAMES
RGLB=Batch1.${subject}
RGSM=${subject}
RGPL=ILLUMINA
RGPU=${flowcell_id}.${lane}.${index}_${subject}
echo "RGID is: $RGID"
echo "RGLB is: $RGLB"
echo "RGSM is: $RGSM"
echo "RGPL is: $RGPL"
echo "RGPU is: $RGPU"
echo ""

##########################################################################################
# MAPPING
##########################################################################################


echo "Adding read group information to ${fastqname%_R1.fastq.gz}.sorted.bam:"
date +"%c"
picard AddOrReplaceReadGroups \
I=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted.bam \
O=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_RG.bam \
RGID=$RGID \
RGLB=$RGLB \
RGPL=$RGPL \
RGPU=$RGPU \
RGSM=$RGSM \
VALIDATION_STRINGENCY=LENIENT
date +"%c"
echo ""

echo "Removing non-primary alignments and ambiguous reads (MAPQ<10) from ${fastqname%_R1.fastq.gz}_sorted_RG.bam:"
date +"%c"
samtools view -b -F 2304 -q 10 ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_RG.bam > ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp.bam
date +"%c"
echo ""

echo "Removing unmapped reads with MAPQ>0 from ${fastqname%_R1.fastq.gz}_sorted_reads_RG.bam:"
date +"%c"
samtools view -b -F 4 ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG_temp.bam > ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam
date +"%c"
echo ""

echo "Removing duplicates from filtered ${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam:"
date +"%c"
picard MarkDuplicates INPUT=${ALIGNED}/${fastqname%_R1.fastq.gz}_sorted_filtered_RG.bam OUTPUT=${ALIGNED}/filtered_bam/${fastqname%_R1.fastq.gz}_sorted_filtered_nodup_RG.bam REMOVE_DUPLICATES=true METRICS_FILE=${ALIGNED}/metrics/${fastqname%_R1.fastq.gz}.filtered_nodup.metrics.txt VALIDATION_STRINGENCY=LENIENT
date +"%c"
echo ""

mv ${fastqname%_R1.fastq.gz}.sorted.bam ${ALIGNED}/raw_files

done

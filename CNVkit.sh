#!/bin/bash

#RUNNING CNVKIT

#download bedfile for the specific exome kit used from company website
#set working directory to users bamfile directory
#create access bedfile for use in command
cnvkit.py access ~/alignment/reference/hg38.fa -o ~/CNVkit_analysis/bedfile/access.bed

#PHASE ONE: NO NORMALISATION

#MATCHED SAMPLES
for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do #edit depending on filenames
 
patient_id=${tumour#trimmed_}
patient_id=${patient_id%_tumour_sorted_filtered_nodup_RG.bam}
normal="trimmed_${patient_id}_normal_sorted_filtered_nodup_RG.bam"
	if [[ -f $normal ]]; then
	echo "Processing patient: $patient_id"
	cnvkit.py batch $tumour --normal $normal \
	--targets ~/CNVkit_analysis/bedfile/Exome-Agilent_V6.bed \
	--fasta ~/alignment/reference/hg38.fa \
	--access ~/CNVkit_analysis/bedfile/access.bed \
	--output-dir ~/CNVkit_analysis --scatter
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done

#UNMATCHED SAMPLES
#used on tumour samples sequenced with same platform as a cohort with matched samples
#reuses reference built from normal pooled samples

for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do #edit depending on filenames
	echo "Processing patient: $patient_id"
	cnvkit.py batch $tumour 
	-r ~/CNVkit_analysis/Reference.cnn 
	-t targets.bed -a antitargets.bed -g access.bed
	--output-dir ~/CNVkit_analysis --scatter
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done


#NO NORMAL SAMPLES 
#used on tumour samples sequenced with different platform than cohort with matched samples

#create flat reference
cnvkit.py reference -o FlatReference.cnn \
-f ~/alignment/reference/hg38.fa \
-t targets.bed -a antitargets.bed

for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do #edit depending on filenames
	echo "Processing patient: $patient_id"
	cnvkit.py batch $tumour \
	-r ~/CNVkit_analysis/FlatReference.cnn 
	-t targets.bed -a antitargets.bed -g access.bed
	--output-dir ~/CNVkit_analysis --scatter
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done

#PHASE TWO: DROPPING LOW COVERAGE AND PURITY NORMALISATION

#set working directory to users CNVkit output directory
#create revised cns files dropping low coverage
for i in *.cnr; do
cnvkit.py segment $i --drop-low-coverage -o ${i%.cnr}.revised.cns
done

#run the call command using revised cns
#if purity is known use that figure, if unknown leave black
for i in *.revised.cns; do
cnvkit.py call $i -y -m clonal --purity X -o ${i%.cns}.call.cns
cnvkit.py scatter ${i%.revised.call.cns}.cnr -s $i -o ${i%.call.cns}-scatter.png
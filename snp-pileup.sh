#!/bin/bash

#CREATE SNP PILEUP FILE FOR FACETS

#download VCF file from FTP server 
#set working directory to users bamfile directory
for tumour in trimmed_*_tumour_sorted_filtered_nodup_RG.bam; do
patient_id=${tumour#trimmed_}
patient_id=${patient_id%_tumour_sorted_filtered_nodup_RG.bam}
normal=trimmed_${patient_id}_normal_sorted_filtered_nodup_RG.bam
	if [[ -f $normal ]]; then
	echo "Processing patient: $patient_id"
	snp-pileup ~/FACETS/VCF/00-common_all_chr.vcf.gz ~/FACETS/$patient_id.pileup $normal $tumour
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done


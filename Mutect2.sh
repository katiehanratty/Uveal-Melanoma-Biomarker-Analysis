#!/bin/sh

#set working directory to users bamfile directory
#ensure to rename files to the sample name used in the BAM reads
for i in *.bam; do
mv i {i%_sorted_filtered_nodup_RG.bam}
done

#create directory for your files
mkdir -p ~/mutect2/normals

######create panel of normals######
#first run every normal sample through tumor only Mutect2
for i in trimmed_patient*_normal; do 
gatk Mutect2 -R ~/alignment/reference/hg38.fa -I $i -tumor $i \
-O ~/mutect2/normals/${i%.bam}.vcf.gz
done 
#make an arg file of all the normal files
ls ~/mutect2/normals/*.vcf.gz > normals_for_pon_vcf.args
#use gatk command to create panel
gatk CreateSomaticPanelOfNormals --vcfs normals_for_pon_vcf.args \ 
-O ~/mutect2/normals/PON.vcf.gz 

######run somatic variant calling######
for tumour in trimmed_*_tumour; do
patient_id=${tumour#trimmed_}
patient_id=${patient_id%_tumour}
normal="trimmed_${patient_id}_normal"
	if [[ -f $normal ]]; then
	echo "Processing patient: $patient_id"
	gatk Mutect2 -I $normal -I $tumour -R ~/alignment/reference/hg38.fa \
	--tumor-sample $tumour --normal-sample $normal \
	--panel-of-normals ~/mutect2/normals/PON.vcf.gz \
	-O ~/mutect2/$patient_id.somatic.vcf.gz
	else
	echo "No normal match found, skipping: $patient_id"
	fi
done


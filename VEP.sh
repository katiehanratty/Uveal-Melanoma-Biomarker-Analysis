#!/bin/sh

#RUNNING VARIANT EFFECT PREDICTOR

#MANUALLY SET WORKING DIRECTORY TO USERS VCF DIRECTORY 

#change file locations as required
for i in *.vcf; do 
vep --cache -i $i -fa ~/alignment/reference/hg38.fa \
--verbose --dir_cache ~/cache \
-o ~/mutect2/VEP/${i%.vcf}.vep \
--everything --fork 4 --vcf
done

#updated on 27/06 to chang eoutput to VCF (--vcf) . better as you only need to handle one file
#to see the filtering on the vcf vs the vep. 

#!/bin/sh

#RUNNING VARIANT EFFECT PREDICTOR

#set working directory to users VCF directory
#change file locations as required
for i in *.vcf; do 
vep --cache -i $i -fa ~/alignment/reference/hg38.fa \
--verbose --dir_cache ~/cache \
-o ~/mutect2/VEP/${i%.vcf}.vep \
--everything --fork 4 
done

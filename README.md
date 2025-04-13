Bioinformatic Analysis Pipelines used for BIO1018: Research Project for project entitled 'Evaluating the Predictive Accuracy of Detection Methods for Molecular Signatures in Uveal Melanoma' by Katie Hanratty. 

All tumour and matched files underwent FastQC.sh, Alignment.sh, BAM_Processing.sh, and Coverage.R scripts.  Files needing trimming following FASTQC run underwent FastQ_Trimming.sh
Files went through three separate pipelines following from this: 

All matched samples and tumour-only samples: 

CNV Calling: CNVkit.sh

All matched tumour-normal samples:

CNV Calling: snp-pileup.sh and FACETS.R scripts

BAP1 Variant Calling: Mutect2.s and VEP.sh scripts.


#!/bin/bash

# Make a new directory for the raw fastq files  
# Within this directory, user should create another directory for fastqc outputs
mkdir -p ~/raw_fastq/FASTQC
# Import raw paired fastq files manually

# Running FastQC 

# Run fastqc, and direct the outputs of the command to user's FASTQC subdirectory
fastqc ~/raw_fastq/*fastq.gz --outdir=~/raw_fastq/FASTQC

# Collate all reports using MultiQC for easier review
multiqc ~/raw_fastq/FASTQC










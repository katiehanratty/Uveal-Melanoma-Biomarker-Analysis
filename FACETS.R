#!/usr/bin/env Rscript

#install and call required packages

install.packages(c("optparse", "remotes"))
remotes::install_github("mskcc/facets")

library(optparse)
library(facets)

#######################################################################

# Load required library
library(facets)

# List all pileup files in the working directory
pileup_files <- list.files(pattern = "sorted_patient.*\\.pileup$")

#create loop for all pileup files

for (file in pileup_files) {
  # Extract patient ID from filenames
  patient_id <- gsub("sorted_(.*)\\.pileup", "\\1", file)
  # Read SNP matrix
  rcmat <- readSnpMatrix(file)
  # Preprocess sample
  preproc <- preProcSample(rcmat, gbuild="hg38", cval=150) # cval setting used for normalisation
  # Process sample
  out <- procSample(preproc)
  # Fit model
  fit <- emcncf(out, maxiter=20)  # maxiter value used for normalisation
  # Save fit object
  saveRDS(fit, file = paste0("fit_", patient_id, ".rds"))
  # Save out object
  saveRDS(out, file = paste0("out_", patient_id, ".rds"))
  # Save plot
  png(filename = paste0("plot_", patient_id, ".png"), width = 800, height = 600)
  plotSample(out, emfit = fit)
  dev.off()
  # Print confirmation
  print(paste("Processed:", file))
}

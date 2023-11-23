#!/usr/bin/env Rscript
library(getopt)
library(methods)
suppressMessages(library(stringr))
suppressMessages(library(data.table))
suppressMessages(library(gRodon))
suppressMessages(library(Biostrings))


spec <- matrix(c(
  'fasta', 'i', 1, "character", "Genome fasta with CDS (ffn).",
  'output', 'o', 1, "character", "Directory for output.",
  'help' , 'h', 0, "logical", "help"
), ncol = 5, byrow = T)

opt <- getopt(spec)

# Help Screen
if ( !is.null(opt$help) | is.null(opt$fasta) | is.null(opt$output) ) {
  cat(getopt(spec, usage=TRUE))
  cat("\n")
  cat("Details:\n")
  q(status=1)
}

fasta <- opt$fasta
output <- opt$output
if( !file.exists(fasta) ) stop(paste("Genome file not found. "), fasta)
if( !dir.exists(output) ) stop("Output directory not found.")

id <- tools::file_path_sans_ext(basename(fasta))

genes <- readDNAStringSet(fasta)
highly_expressed <- grepl("ribosomal protein",names(genes),ignore.case = T)
pred <- predictGrowth(genes, highly_expressed)

fwrite(data.table(t(pred)), paste0(output,"/",id,".csv"))
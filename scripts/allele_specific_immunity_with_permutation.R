# Set directory
source("~/OneDrive - wehi.edu.au/antigen_distance_calculation/allele_specific_immunity_with_permutation.R")

path = "~/OneDrive - wehi.edu.au/ama1_albinama/"
source = "~/OneDrive - wehi.edu.au/ama1_albinama/Compare2HeteroVect_corrected.R"
path_fasta = "~/OneDrive - wehi.edu.au/amp-seq_fasta_high_quality/msp1_translated.fasta"
Antigen = "MSP1"
permutation = 10000

allele_specific_immunity(path,source, path_fasta, Antigen, permutation )

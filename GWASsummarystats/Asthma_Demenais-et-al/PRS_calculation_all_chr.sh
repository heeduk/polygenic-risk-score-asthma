#!/bin/bash
#SBATCH --job-name=PRS
#SBATCH --output=PRS_%j.out

~/local/bin/plink \
  --bfile /path/to/1KGP/1kgp_merged_nodup \
  --score /path/to/GWASsummarystats/Asthma_Demenais-et-al/asthma_allchr.prs 1 2 3 sum \
  --out /path/to/GWASsummarystats/Asthma_Demenais-et-al/PRS_results/1kgp_allchr_asthmaPRS

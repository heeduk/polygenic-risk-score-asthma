#!/bin/bash
##SBATCH --nodes=1
##SBATCH --time=01:00:00
##SBATCH --mem=8GB
##SBATCH --cpus-per-task=4
#SBATCH --job-name=PRS
#SBATCH --output=PRS_%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=hoh5@ncsu.edu

~/local/bin/plink \
  --bfile /home/wolftech/hoh5/Personal_project/1KGP/1kgp_merged_nodup \
  --score /home/wolftech/hoh5/Personal_project/GWASsummarystats/Asthma_Demenais-et-al/asthma_allchr.prs 1 2 3 sum \
  --out /home/wolftech/hoh5/Personal_project/GWASsummarystats/Asthma_Demenais-et-al/PRS_results/1kgp_allchr_asthmaPRS

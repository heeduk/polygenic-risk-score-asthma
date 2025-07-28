#!/bin/bash
#SBATCH --job-name=merge_PLINK
#SBATCH --output=merge_PLINK_%j.out

~/local/bin/plink \
  --bfile /path/to/1KGP/1kgp_chr1_nodup \
  --merge-list /path/to/1KGP/chr_list.txt \
  --make-bed \
  --out /path/to/1KGP/1kgp_merged_nodup

#!/bin/bash
#SBATCH --job-name=removeduplicates_chr$1
#SBATCH --output=removeduplicates_chr$1_%j.out

chr=$1
cd /path/to/1KGP/

# Get list of duplicates for this chromosome only
cut -f2 1kgp_chr${chr}.bim | sort | uniq -d > duplicates_chr${chr}.txt

# Remove duplicates using the chromosome-specific duplicates list
~/local/bin/plink --bfile 1kgp_chr${chr} \
  --exclude duplicates_chr${chr}.txt \
  --make-bed --out 1kgp_chr${chr}_nodup

#!/bin/bash
##SBATCH --nodes=1
##SBATCH --time=01:00:00
##SBATCH --mem=8GB
##SBATCH --cpus-per-task=4
#SBATCH --job-name=removeduplicates_chr$1
#SBATCH --output=removeduplicates_chr$1_%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=hoh5@ncsu.edu

chr=$1
cd /home/wolftech/hoh5/Personal_project/1KGP/

# Get list of duplicates for this chromosome only
cut -f2 1kgp_chr${chr}.bim | sort | uniq -d > duplicates_chr${chr}.txt

# Remove duplicates using the chromosome-specific duplicates list
~/local/bin/plink --bfile 1kgp_chr${chr} \
  --exclude duplicates_chr${chr}.txt \
  --make-bed --out 1kgp_chr${chr}_nodup

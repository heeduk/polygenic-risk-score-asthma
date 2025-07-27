#!/bin/bash
##SBATCH --nodes=1
##SBATCH --time=01:00:00
##SBATCH --mem=8GB
##SBATCH --cpus-per-task=4
#SBATCH --job-name=merge_PLINK
#SBATCH --output=merge_PLINK_%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=hoh5@ncsu.edu

~/local/bin/plink \
  --bfile /home/wolftech/hoh5/Personal_project/1KGP/1kgp_chr1_nodup \
  --merge-list /home/wolftech/hoh5/Personal_project/1KGP/chr_list.txt \
  --make-bed \
  --out /home/wolftech/hoh5/Personal_project/1KGP/1kgp_merged_nodup

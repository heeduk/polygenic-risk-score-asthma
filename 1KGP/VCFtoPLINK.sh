#!/bin/bash
##SBATCH --nodes=1
##SBATCH --time=01:00:00
##SBATCH --mem=8GB
##SBATCH --cpus-per-task=4
#SBATCH --job-name=VCFtoPLINK
#SBATCH --output=VCFtoPLINK_%j.out
#SBATCH --mail-type=END
#SBATCH --mail-user=hoh5@ncsu.edu

chr=$1

~/local/bin/plink --vcf /home/wolftech/hoh5/Personal_project/1KGP/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
  --make-bed --out /home/wolftech/hoh5/Personal_project/1KGP/1kgp_chr${chr}

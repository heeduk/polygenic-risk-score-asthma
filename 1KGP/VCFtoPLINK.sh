#!/bin/bash
#SBATCH --job-name=VCFtoPLINK
#SBATCH --output=VCFtoPLINK_%j.out

chr=$1

~/local/bin/plink --vcf /path/to/1KGP/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
  --make-bed --out /path/to/1KGP/1kgp_chr${chr}

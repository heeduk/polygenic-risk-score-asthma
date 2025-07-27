# 🧬 Polygenic Risk Score (PRS) Pipeline with 1000 Genomes and Asthma GWAS

This project demonstrates an end-to-end pipeline to calculate Polygenic Risk Scores (PRS) using the public 1000 Genomes Project genotype data and asthma GWAS summary statistics. The pipeline covers data download, preprocessing, quality control, format conversion, scoring with PLINK, and initial summary.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Directory Structure](#directory-structure)
- [Step-by-Step Workflow](#step-by-step-workflow)
- [Output and Interpretation](#output-and-interpretation)
- [Next Steps and Analysis Ideas](#next-steps-and-analysis-ideas)
- [References and Resources](#references-and-resources)
- [Contact](#contact)

---

## Project Overview

Polygenic Risk Scores (PRS) estimate the genetic predisposition of individuals to a trait or disease by aggregating effects across many genetic variants. This repo implements a reproducible pipeline using:

- Genotypes: 1000 Genomes Project phase 3 data
- Summary statistics: GWAS Catalog asthma GWAS (GCST005212)
- Tools: PLINK 1.9 (local binary)
- Analysis environment: Bash scripts with SLURM scheduler for job submission

The goal is to convert variant data, clean and harmonize it, score individuals chromosome-wise, merge results for full-genome PRS, and explore basic summary statistics.

---

## Directory Structure

```

.
├── bin/                       \# Local binaries (plink, tools)
├── data/
│   ├── 1KGP/                  \# 1000 Genomes VCF and PLINK files
│   └── GWASsummarystats/      \# GWAS summary statistics files
├── scripts/                   \# Bash job scripts
├── results/
│   ├── PRS_results/           \# Scoring result profiles
│   └── plots/                 \# (optional) plot outputs
└── README.md

```

---

## Step-by-Step Workflow

### 1. Environment Setup - Tools & Paths
```

mkdir -p ~/local/bin
export PATH="$HOME/local/bin:$PATH"

# Add the above export to your ~/.bashrc for persistence

```

### 2. Data Download

#### 1000 Genomes (Example for Chr 1)
```

wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ALL.chr1.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz.tbi

```
*(Use looping scripts for chromosomes 1–22)*

#### GWAS Summary Statistics for Asthma
```

wget https://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST005001-GCST006000/GCST005212/harmonised/29273806-GCST005212-EFO_0000270.h.tsv.gz
wget https://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST005001-GCST006000/GCST005212/harmonised/readme.txt

```

### 3. Install PLINK Locally
```

cd ~/local/bin
wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20201019.zip
unzip plink_linux_x86_64_20201019.zip
chmod +x plink

```

### 4. VCF to PLINK Conversion Script (`VCFtoPLINK.sh`)
Example for processing any chromosome passed as `$1`:
```

chr=$1
~/local/bin/plink --vcf /home/wolftech/hoh5/Personal_project/1KGP/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5b.20130502.genotypes.vcf.gz \
--make-bed --out /home/wolftech/hoh5/Personal_project/1KGP/1kgp_chr\${chr}

```

### 5. Assign SNP IDs in `.bim` Files
Since SNP IDs are missing (`.`), assign unique IDs:
```

chr=\$1
awk '{print \$1"\t"\$1":"\$4":"\$5":"\$6"\t"\$3"\t"\$4"\t"\$5"\t"$6}' \
  1kgp_chr${chr}.bim > 1kgp_chr${chr}_rsID.bim
mv 1kgp_chr${chr}.bim 1kgp_chr${chr}.bim.original.backup
mv 1kgp_chr${chr}_rsID.bim 1kgp_chr\${chr}.bim

```

### 6. Create Chromosome-specific PRS Scoring Files (`create_PRS_scoring_file.sh`)
Extract effect alleles, variant IDs, and beta values from GWAS data per chromosome:
```

chr=$1
zcat /home/wolftech/hoh5/Personal_project/GWASsummarystats/Asthma_Demenais-et-al/29273806-GCST005212-EFO_0000270.h.tsv.gz \
| awk -F'\t' -v chr=$chr 'NR==1 {
for (i=1; i<=NF; i++) h[\$i] = i
next
}
\$h["chromosome"] == chr {
vid = \$h["chromosome"] ":" \$h["base_pair_location"] ":" \$h["hm_other_allele"] ":" \$h["hm_effect_allele"]
print vid, \$h["hm_effect_allele"], $h["hm_beta"]
}' > /home/wolftech/hoh5/Personal_project/GWASsummarystats/Asthma_Demenais-et-al/asthma_chr${chr}.prs

```

Run for all chromosomes and then concatenate into one PRS file.

### 7. Remove Duplicate SNPs Per Chromosome (`remove_duplicates.sh`)
```

chr=$1
cut -f2 1kgp_chr${chr}.bim | sort | uniq -d > duplicates_chr${chr}.txt
~/local/bin/plink --bfile 1kgp_chr${chr} --exclude duplicates_chr${chr}.txt --make-bed --out 1kgp_chr${chr}_nodup

```

### 8. Merge Chromosomes into Combined Dataset
Prepare list of files from chr2–22 and run PLINK merge:
```

echo "/home/wolftech/hoh5/Personal_project/1KGP/1kgp_chr2_nodup" > chr_list.txt
for chr in {3..22}; do
echo "/home/wolftech/hoh5/Personal_project/1KGP/1kgp_chr\${chr}_nodup" >> chr_list.txt
done

~/local/bin/plink --bfile 1kgp_chr1_nodup --merge-list chr_list.txt --make-bed --out 1kgp_merged_nodup

```

### 9. Calculate Genome-wide PRS (`PRS_calculation_all_chr.sh`)
```

~/local/bin/plink --bfile 1kgp_merged_nodup \
--score /home/wolftech/hoh5/Personal_project/GWASsummarystats/Asthma_Demenais-et-al/asthma_allchr.prs 1 2 3 sum \
--out /home/wolftech/hoh5/Personal_project/GWASsummarystats/Asthma_Demenais-et-al/PRS_results/1kgp_allchr_asthmaPRS

```

---

## Output and Interpretation

Example lines from a `.profile` PRS output file:
| FID      | IID      | PHENO | CNT   | CNT2  | SCORESUM |
|----------|----------|-------|-------|-------|----------|
| HG00096  | HG00096  |  -9   | 1218  | 1203  | 2.41684  |
| HG00097  | HG00097  |  -9   | 1218  | 1199  | 2.46873  |

- **FID / IID** — sample IDs matching 1000 Genomes
- **PHENO** — phenotype (here all missing, coded as -9, since 1000 Genomes has no phenotype)
- **CNT** — number of variants used for scoring
- **SCORESUM** — final polygenic risk score

Values indicate the PRS scores are successfully computed.

---

## Next Steps and Analysis Ideas

- Plot score distribution via R or Python (histograms, density plots).
- Stratify scores by ancestry groups (use the 1KGP panel file).
- Calculate summary statistics: means, variances, compare subpopulations.
- Explore score associations with phenotypes if available.
- Extend pipeline to other traits or datasets.

---

## References and Resources

- [PLINK](https://www.cog-genomics.org/plink/)
- [1000 Genomes Project](https://www.internationalgenome.org/)
- [GWAS Catalog Asthma Study GCST005212](https://www.ebi.ac.uk/gwas/studies/GCST005212)
- Scripts and job submissions designed for SLURM workload manager
- Local standalone binary setup to avoid system-wide installs

---

## Contact

For questions or suggestions, please contact:

- [Your Name or Handle]
- Email: hoh5@ncsu.edu (example)
- GitHub: [https://github.com/heeduk](https://github.com/heeduk)

---

*This README serves as both documentation and technical showcase of a PRS workflow incorporating public genotype and GWAS data resources.*

---

```
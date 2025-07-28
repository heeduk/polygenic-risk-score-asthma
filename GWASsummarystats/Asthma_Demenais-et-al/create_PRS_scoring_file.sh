#!/bin/bash
#SBATCH --job-name=create_PRS
#SBATCH --output=create_PRS_%j.out

chr=$1

zcat /path/to/GWASsummarystats/Asthma_Demenais-et-al/29273806-GCST005212-EFO_0000270.h.tsv.gz \
| awk -F'\t' -v chr=$chr 'NR==1 {
    for (i=1; i<=NF; i++) h[$i] = i
    next
}
$h["chromosome"] == chr {
    vid = $h["chromosome"] ":" $h["base_pair_location"] ":" $h["hm_other_allele"] ":" $h["hm_effect_allele"]
    print vid, $h["hm_effect_allele"], $h["hm_beta"]
}' > /path/to/GWASsummarystats/Asthma_Demenais-et-al/asthma_chr${chr}.prs

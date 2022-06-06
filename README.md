# Mapping-within-host-antigenic-escape

## SHAPEIT4 

To perform high quality haplotype phasing, we used [SHAPEIT4 v4.2](https://odelaneau.github.io/shapeit4/). Pre-processed vcf files by [sm-SNIPER](https://github.com/myonaung/sm-SNIPER) now with PS tag were merged and indexed. We used the following command:

```
out=data/SHAPEIT_output

for chr in {01..14}; do
    map=SHAPEIT_input/3d7_chr${chr}.gmap
    vcf=SHAPEIT_input/merged_whatshap.vcf.gz
    shapeit4.2 --input ${vcf}  --use-PS 0.0001 --region Pf3D7_${chr}_v3 --output ${out}/chr${chr}_shapeit.vcf --map ${map} 
done


for f in *_shapeit.vcf; do
    bgzip -c ${f} > ${f}.gz
    tabix ${f}.gz
done

bcftools concat -a *_shapeit.vcf.gz -o phased_final.vcf
```

`.gmap` file of each chromosome is based on the polymorphic sites found in the population.

### Notes on GMAP file for *Plasmodium falciparum* 

GMAP is a tab-delimited txt file with 3 columns as follows: 
- pos: containing the base-pair position
- chr: this should be a number between 1-14 (i.e, "Pf3D7_([0-9]+)_v3")
- cM: this is the base-pair position divided by the length of 1cM with the most recent estimate for *Plasmodium falciparum* is 13.5kb per centimorgan.

## Calculating changes in individual polymorphic residues of each antigen and the risk of clinical malaria

The following analyses were done on translated dna sequences of coding regions (i.e. AA acid sequences) from the aligned FASTA files. However, the script and analyses should be the same for any dna level calculation. The following analyses were done in R v4.0.0.  

### Algorithm
The following script will work for any analysis that has the exact same format of input datasets - [`amp_seq_metadata.csv`](https://github.com/myonaung/Mapping-within-host-antigenic-escape/tree/main/examples), `molFOI_4422.csv`, and `FASTA file with header that is similar to samples ID from amp_seq_metadata.csv`. It calculates polymorphic sites that higher turnover rate when transitioning into symptomatic clinical episodes comparing to that of non-symptomatic clinical episodes within an individual. Scoring function- Compare2HeteroVect_corrected.R and the main function -allele_specific_immunity_with_permutation.R . Scoring is done based on changes of each polymorphic in each clinical episode transition i.e, transition to symptomatic vs transition to asymptomatic states within the same individual (change = 1, no change =0). The mean of scores (total sum/number of transition=value or 50/100 = 0.5) for each polymorphic sites are calculated for each category separately (i.e., transition to symptomatic vs transition to asymptomatic states). Polymorphic sites that has higher turnover in symptomatic transitions (mean scores in symptomatic transition >  mean scores in asymptomatic transition) are assumed to be associated with immune escape. To differentiate polymorphic sites associated with virulence rather than immune escape, polymorphisms under certain threshold was removed even though they can be higher turnover with symptomatic transitions (i.e. polymorphic sites that found at least 10% within symptomatic transitions ). 

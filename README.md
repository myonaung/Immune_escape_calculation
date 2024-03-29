# Mapping-within-host-antigenic-escape

Table of contents
----------------
  * [Authors](#authors)
  * [SHAPEIT4](#SHAPEIT4)
  * [Algorithm to measure within-host allelic turnover](#Algorithm-to-measure-within-host-allelic-turnover)
  * [Binary logistic regression using glm R package](#Binary-logistic-regression-using-glm-R-package)

## Authors

- [Myo T. Naung](https://github.com/myonaung)
- [Swapnil Tichkule](https://github.com/Swap90)


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

## Algorithm to measure within-host allelic turnover

The following analyses were done on translated dna sequences of coding regions (i.e. AA acid sequences) from the aligned FASTA files. However, the script and analyses should be the same for any dna level calculation. The following analyses were done in R v4.0.0.  

### Algorithm
The following script will work for any analysis that has the exact same format of input datasets - [`amp_seq_metadata.csv`](https://github.com/myonaung/Immune_escape_calculation/tree/main/examples), [`molFOI_4422.csv`](https://github.com/myonaung/Immune_escape_calculation/tree/main/examples), and **FASTA** file with **header** that is similar to **samples ID** from **amp_seq_metadata.csv**. It identify polymorphic sites that has higher turnover rate when transitioning into symptomatic clinical episodes comparing to that of non-symptomatic clinical episodes within an individual. Scoring function- [`Compare2HeteroVect_corrected.R`](https://github.com/myonaung/Immune_escape_calculation/tree/main/scripts) and the main function - [`allele_specific_immunity_with_permutation.R`](https://github.com/myonaung/Immune_escape_calculation/tree/main/scripts/allele_specific_immunity_with_permutation.R). 

Scoring is done based on changes of each polymorphic in each clinical episode transition i.e, transition to symptomatic vs transition to asymptomatic states within the same individual (change = 1, no change =0). The mean of scores (total sum/number of transition=value or 50/100 = 0.5) for each polymorphic sites are calculated for each category separately (i.e., transition to symptomatic vs transition to asymptomatic states). Polymorphic sites that has higher turnover in symptomatic transitions (mean scores in symptomatic transition >  mean scores in asymptomatic transition) are assumed to be associated with immune escape. To differentiate polymorphic sites associated with virulence from immune escape, polymorphisms found under certain threshold with asymptomatic episodes was removed even though they have higher turnover rate within symptomatic transitions (i.e. polymorphic sites that found under 5% with asymptomatic episodes). The analysis can be achived as follow:

Example script can also be found in [`allele_specific_immunity_with_permutation_cal.R`](https://github.com/myonaung/Immune_escape_calculation/tree/main/scripts/allele_specific_immunity_with_permutation_cal.R). 

```
source("allele_specific_immunity_with_permutation_cal.R")

path = "input_files"
source = "Compare2HeteroVect_corrected.R"
path_fasta = "path/ama1_high_quality_hetero_pos_translated.fasta"
Antigen = "AMA1"
permutation = 10000 #number of permutation to simulate null hypothesis 

#running the analysis
allele_specific_immunity(path,source, path_fasta, Antigen, permutation)
```

Random permutation of dataset is done for null hypothesis testing. Basically, it is the comparision of observed dataset with simulated dataset and calculate probability of observing real data in simulated dataset `obs probability`. Higher values (for example, >0.5) indicates that the observed data is mostly likely to be found by chance. 


<p align="center">
  <img src="./images/allele specific algorithm.png" height=100% width=100% >
</p>

<h4 align="center">Figure 1: Description of EVADE algorithm including infection simulations.</h4>

## Binary logistic regression using glm R package
The following R-wrapper function [`logistic_regression_function.R`](https://github.com/myonaung/Immune_escape_calculation/tree/main/scripts) is used to build univariate model for each polymorphic sites adjusted for cofounding variables such as molecular force of infection (molFOI) of each children.  The response variable is whether an individual is experiencing symptomatic or non-symptomatic clinical episodes in relation to changes in each polymorphic positions. Multiplicity of infection (MOI up to 2 clones per infection with minor clone proportion greater than 20%) is included in the analysis where  possible. The following example used the subset of AMA1 sequences from our sequencing cohorts.

```
require(caret)
library(tidyverse)
library(lme4)

#wrapper function
source("logistic_regression_function.R")

#input
file_csv = "AMA1_2022-04-20_xgboost_input.csv"
antigen = "AMA1"
out_path = "antigen_distance_calculation/"

#running the analysis
logistic_regression(file_csv)
```
We didn’t split original dataset into train/test set here and calculate ROC curve etc since we are comparing the results from above analysis. Hence, p-value and direction of correlation were the interest of the analysis. 

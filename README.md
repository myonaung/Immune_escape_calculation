# Mapping-within-host-antigenic-escape

## SHAPEIT4 

To perform high quality haplotype phasing, we used [SHAPEIT4 v4.2](https://odelaneau.github.io/shapeit4/). Pre-processed vcf files by [sm-SNIPER](https://github.com/myonaung/sm-SNIPER) now with PS tag were merged and indexed. We used the following command:

```
out=data/SHAPEIT_output

for chr in {01..14}; do
    map=SHAPEIT_input/3d7_chr${chr}.gmap
    vcf=SHAPEIT_input/merged_whatshap.vcf.gz
    shapeit4.2	--input ${vcf} \
		    	--use-PS 0.0001 \ 
		    	--region Pf3D7_${chr}_v3 \
		    	--output ${out}/chr${chr}_shapeit.vcf \
               	--map ${map} 
done


for f in *_shapeit.vcf; do
    bgzip -c ${f} > ${f}.gz
    tabix ${f}.gz
done

bcftools concat -a *_shapeit.vcf.gz -o phased_final.vcf
```

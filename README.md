## End selection in cell-free DNA enhances noninvasive prenatal testing and cancer diagnosis
---
This repository contains the scripts and related files for Ju et al.
Distributed under the [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/ "CC BY-NC-ND")
license for **personal and academic usage only**.

## Annotation files under `anno` directory
Note that all the annotation files we provided are built for NCBI GRCh38 (hg38) reference genome.
1. `hg38.info`: chromosome size information for hg38 genome;
2. `hsNuc0390101.DANPOSPeak.sorted.bed.gz` and `hsNuc0260501.DANPOSPeak.sorted.bed.gz`:
nucleosome tracks for GM12878 and K562 cell lines, respectively. The raw data was downlaoded from NucMap:
[hsNuc0390101](https://download.cncb.ac.cn/nucmap/organisms/v1/Homo_sapiens/byDataType/Nucleosome_peaks_DANPOS/Homo_sapiens.hsNuc0390101.nucleosome.DANPOSPeak.bed.gz), and
[hsNuc0260501](https://download.cncb.ac.cn/nucmap/organisms/v1/Homo_sapiens/byDataType/Nucleosome_peaks_DANPOS/Homo_sapiens.hsNuc0260501.nucleosome.DANPOSPeak.bed.gz).
We sorted the data using the following commands:
```
zcat Homo_sapiens.hsNuc0390101.nucleosome.DANPOSPeak.bed.gz | perl -lane '$c=($F[1]+$F[2])>>1; print join("\t", $F[0], $c-73, $c+1+73, $F[3])' | sort -k1,1 -k2,2n | gzip >hsNuc0390101.DANPOSPeak.sorted.bed.gz
zcat Homo_sapiens.hsNuc0260501.nucleosome.DANPOSPeak.bed.gz | perl -lane '$c=($F[1]+$F[2])>>1; print join("\t", $F[0], $c-73, $c+1+73, $F[3])' | sort -k1,1 -k2,2n | gzip >hsNuc0260501.DANPOSPeak.sorted.bed.gz
```
These two files could be directly used as nputs for the following scripts.

## Noninvasive prenatal testing scripts under `NIPT` directory
The main program is `nipt`. You can run it without parameters to see the usage:
```
Usage: NIPT/nipt <nucleosome.track.bed[.gz]> <bed.list>

The "bed.list" file should contains 3 columns: sid /path/to/bed[.gz] category
The bed files could be gzipped, but must be Single-End data
The category should be either "control" or "testing" for all samples
```

There are 2 compulsory paramters:
1. `nucleosome.track.bed` contains the nucleosome track annotations;
2. `SE.bed.list` file must contains 3 columns: sampleIDs, path to the bed files, and a category
(either control or testing). An example file `example.bed.list.nipt` was provided.

The bed files could be plain text or gzipped. We provide a script `se_sam2bed.pl` for converting bam file to bed format.
There would be 2 output files: `Z-score.standard` and `Z-score.with.end.selection`, each contains Z-scores for samples with "testing" label.

Note that the current script for NIPT only support single-end data.

## Cancer diagnosis scripts under `Cancer.diagnosis` directory
The main program is `calc.N-index`. Call it without parameters to see the usage:
```
Usage: calc.N-index <genome.info> <nucleosome.center.bed[.gz]> <PE.bed.list> [extend=73] [thread=4] [autosome.only=y|n]

Written by Kun Sun (sunkun@szbl.ac.cn). (c) Shenzhen Bay Laboratory.

This program is designed to calculate N-index for each sample in 'bed.list',
which should contain (at least) 2 columns: sampleID and /path/to/bed[.gz].
The current program only supports Paired-End data; gzipped bed file is supported.
Output: Sid Total Within N-index

```
There are 3 compulsory paramters:
1. `genome.info` contains the size information for each chromosome in human genome;
2. `nucleosome.track.bed` contains the nucleosome track annotations;
3. `PE.bed.list` file contains sampleIDs and path to the bed files in 2-column format.
An example file `example.bed.list.cancer` was provided.

The bed files could be plain text or gzipped. We provide a script `pe_sam2bed.pl` for converting bam file to bed format.
The results would be written to standard output, which contains 4 columns: the 1st column is sampleID in `PE.bed.list` and the 4th column is N-index.

Note that the current script for cancer diagnosis only support paired-end data.


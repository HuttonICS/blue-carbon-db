#!/bin/bash

#SBATCH --partition=short
#SBATCH --cpus-per-task=6
#SBATCH --mem=8G
#SBATCH --begin=02:00:00
#SBATCH --job-name="rbclGet"

source activate qiime2-2023.7

qiime rescript get-ncbi-data \
--p-query 'rbcl[All Fields] AND 00000001000[SLEN] : 00000010000[SLEN]' \
--p-n-jobs 5 \
--o-sequences rbcl/ncbi-refseqs-unfiltered-rbcl.qza \
--o-taxonomy rbcl/ncbi-refseqs-taxonomy-unfiltered-rbcl.qza

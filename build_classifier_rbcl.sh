#!/bin/bash

#SBATCH --partition=short
#SBATCH --cpus-per-task=2
#SBATCH --mem=50G
#SBATCH --job-name="BasicRBCL"

source activate qiime2-2023.7

####### create classifier

qiime rescript evaluate-fit-classifier \
--i-sequences rbcl/basic-rbcl-ref-seqs-derep-cull-removed.qza \
--i-taxonomy rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed.qza \
--p-n-jobs 2 \
--o-classifier rbcl/ncbi-rbcl-basic-refseqs-classifier.qza \
--o-evaluation rbcl/ncbi-rbcl-basic-refseqs-classifier-evaluation.qzv \
--o-observed-taxonomy rbcl/ncbi-rbcl-basic-refseqs-predicted-taxonomy.qza

qiime rescript evaluate-taxonomy \
--i-taxonomies rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed.qza rbcl/ncbi-rbcl-basic-refseqs-predicted-taxonomy.qza \
--p-labels ref-taxonomy predicted-taxonomy \
--o-taxonomy-stats rbcl/basic-rbcl-taxonomy-evaluation.qzv

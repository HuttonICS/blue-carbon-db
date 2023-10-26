#!/bin/bash

#SBATCH --partition=short
#SBATCH --cpus-per-task=8
#SBATCH --mem=10G
#SBATCH --job-name="BasicRBCL"

source activate qiime2-2023.7

###filter the taxa out you don't need

qiime taxa filter-seqs \
--i-sequences rbcl/ncbi-refseqs-unfiltered-rbcl.qza \
--i-taxonomy rbcl/ncbi-refseqs-taxonomy-unfiltered-rbcl.qza \
--p-exclude 'k__Synthetic and Chimeric','k__Environmental samples','k__Unassigned' \
--o-filtered-sequences rbcl/ncbi-refseqs-filtered-rbcl.qza


qiime rescript filter-taxa \
--i-taxonomy rbcl/ncbi-refseqs-taxonomy-unfiltered-rbcl.qza \
--m-ids-to-keep-file rbcl/ncbi-refseqs-filtered-rbcl.qza \
--o-filtered-taxonomy rbcl/ncbi-refseqs-taxonomy-filtered-rbcl.qza

##dereplicate and cull

qiime rescript dereplicate \
--i-sequences rbcl/ncbi-refseqs-filtered-rbcl.qza  \
--i-taxa rbcl/ncbi-refseqs-taxonomy-filtered-rbcl.qza \
--p-mode 'uniq' \
--p-threads 8 \
--o-dereplicated-sequences rbcl/basic-rbcl-ref-seqs-derep.qza \
--o-dereplicated-taxa rbcl/basic-rbcl-ref-tax-culled-derep.qza 

qiime rescript cull-seqs \
--i-sequences rbcl/basic-rbcl-ref-seqs-derep.qza \
--p-n-jobs 8 \
--p-num-degenerates 1 \
--p-homopolymer-length 8 \
--o-clean-sequences rbcl/basic-rbcl-ref-seqs-derep-cull.qza

########## edit taxo and remove sequences and taxonomy I cannot reclassify due to lack of information.

qiime rescript edit-taxonomy \
--i-taxonomy rbcl/basic-rbcl-ref-tax-culled-derep.qza \
--p-search-strings 'k__Eukaryota;p__Eukaryota;c__Pelagophyceae' 'k__Eukaryota;p__Eukaryota;c__Phaeophyceae' 'k__Eukaryota;p__Eukaryota;c__Eustigmatophyceae' 'k__Eukaryota;p__Eukaryota;c__Xanthophyceae' 'k__Eukaryota;p__Eukaryota;c__Bolidophyceae' 'k__Eukaryota;p__Eukaryota;c__Raphidophyceae' 'k__Eukaryota;p__Eukaryota;c__Pinguiophyceae' 'k__Eukaryota;p__Eukaryota;c__Chrysophyceae' 'k__Eukaryota;p__Eukaryota;c__Synchromophyceae' 'k__Eukaryota;p__Eukaryota;c__Phaeosacciophyceae' 'k__Eukaryota;p__Eukaryota;c__Phaeothamniophyceae' 'k__Eukaryota;p__Eukaryota;c__Dictyochophyceae' 'k__Eukaryota;p__Eukaryota;c__Olisthodiscophyceae' 'k__Eukaryota;p__Eukaryota;c__Dinophyceae' 'k__Eukaryota;p__Eukaryota;c__Chrysomerophyceae' 'k__Eukaryota;p__Eukaryota;c__Cryptophyceae' 'k__Eukaryota;p__Eukaryota;c__Synurophyceae' 'k__Eukaryota;p__Eukaryota;c__Centroplasthelida' 'k__Eukaryota;p__Eukaryota;c__Glaucocystophyceae' 'k__Eukaryota;p__Eukaryota;c__Aurearenophyceae' \
--p-replacement-strings 'k__Eukaryota;p__Ochrophyta;c__Pelagophyceae' 'k__Eukaryota;p__Ochrophyta;c__Phaeophyceae' 'k__Eukaryota;p__Ochrophyta;c__Eustigmatophyceae' 'k__Eukaryota;p__Ochrophyta;c__Xanthophyceae' 'k__Eukaryota;p__Ochrophyta;c__Bolidophyceae' 'k__Eukaryota;p__Ochrophyta;c__Raphidophyceae' 'k__Eukaryota;p__Ochrophyta;c__Pinguiophyceae' 'k__Eukaryota;p__Ochrophyta;c__Chrysophyceae' 'k__Eukaryota;p__Ochrophyta;c__Synchromophyceae' 'k__Eukaryota;p__Ochrophyta;c__Phaeosacciophyceae' 'k__Eukaryota;p__Ochrophyta;c__Phaeothamniophyceae' 'k__Eukaryota;p__Ochrophyta;c__Dictyochophyceae' 'k__Eukaryota;p__Ochrophyta;c__Dictyochophyceae' 'k__Eukaryota;p__Myzozoa;c__Dinophyceae' 'k__Eukaryota;p__Ochrophyta;c__Chrysomerophyceae' 'k__Eukaryota;p__Cryptophyta;c__Cryptophyceae' 'k__Eukaryota;p__Ochrophyta;c__Synurophyceae' 'k__Eukaryota;p__Ochrophyta;c__Centroplasthelida' 'k__Eukaryota;p__Glaucophyta;c__Glaucocystophyceae' 'k__Eukaryota;p__Ochrophyta;c__Aurearenophyceae' \
--o-edited-taxonomy rbcl/basic-rbcl-ref-tax-culled-derep-fixed.qza

qiime taxa filter-seqs \
--i-sequences rbcl/basic-rbcl-ref-seqs-derep-cull.qza \
--i-taxonomy rbcl/basic-rbcl-ref-tax-culled-derep-fixed.qza \
--p-exclude 'k__Eukaryota;p__Eukaryota;c__Eukaryota;o__Eukaryota;f__Eukaryota' \
--o-filtered-sequences rbcl/basic-rbcl-ref-seqs-derep-cull-removed.qza

qiime rescript filter-taxa \
--i-taxonomy rbcl/basic-rbcl-ref-tax-culled-derep-fixed.qza \
--m-ids-to-keep-file rbcl/basic-rbcl-ref-seqs-derep-cull-removed.qza \
--o-filtered-taxonomy rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed.qza

######## visualise for checks

qiime metadata tabulate \
--m-input-file rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed.qza \
--o-visualization rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed-table.qzv

qiime metadata tabulate \
--m-input-file rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed.qza \
--o-visualization rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed-table.qzv
    
qiime rescript evaluate-taxonomy \
--i-taxonomies rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed.qza \
--o-taxonomy-stats rbcl/basic-rbcl-ref-tax-culled-derep-fixed-removed-eval.qza

qiime rescript evaluate-seqs \
--i-sequences rbcl/basic-rbcl-ref-seqs-derep-cull-removed.qza \
--p-kmer-lengths 16 8 4 2 \
--o-visualization rbcl/basic-rbcl-ref-seqs-derep-cull-removed-eval.qzv


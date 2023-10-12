# blue-carbon-db


This repository contains two Qiime2 formatted databases produced for a Natural England and the James Hutton Limited project "Testing the validity of using eDNA for carbon origin analysis from sediment cores". This repository contains the databases and the scripts used to create them.
Two databases have been generated using data available from the NCBI, one for the plastid gene rbcl and one for 18S rRNA gene of molluscs. 

These custom reference sequence databases were generated and curated using RESCRIPt in the Qiime2 environment. 
The owners of this repository are not the developers of RESCRIPt or Qiime2, you can find more information on those platforms and plugins here: 

RESCRIPt, https://github.com/bokulich-lab/RESCRIPt
Qiime2, https://docs.qiime2.org/2023.7/ 

# Installing Qiime2 and RESCRIPt

The following instructions are to install Qiime2 and RESCRIPt on a High Performance Computing (HPC) Linux cluster.

Download the Qiime2 package
```
wget https://data.qiime2.org/distro/core/qiime2-2023.7-py38-linux-conda.yml
```
Create a new environment and install the downloaded file into that environment
```
conda env create -n qiime2-2023.7 --file qiime2-2023.7-py38-linux-conda.yml
```
Delete the install file as a clean up step 
```
rm qiime2-2023.7-py38-linux-conda.yml
```
Activate your new Qiime2 environment
```
conda activate qiime2-2023.7
```
Install dependencies for RESCRIPt
```
conda install -c conda-forge -c bioconda -c qiime2 -c https://packages.qiime2.org/qiime2/2023.7/tested/ -c defaults \
  xmltodict 'q2-types-genomics>2023.7' ncbi-datasets-pylib
```
Install the RESCRIPt
```
pip install git+https://github.com/bokulich-lab/RESCRIPt.git
```
check install
```
qiime dev refresh-cache
qiime --help
```
If you use Qiime2 and RESCRIPt in your research, please cite the papers:

Bolyen, E., Rideout, J.R., Dillon, M.R., Bokulich, N.A., Abnet, C.C., Al-Ghalith, G.A., Alexander, H., Alm, E.J., Arumugam, M., Asnicar, F. and Bai, Y., 2019. Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. Nature biotechnology, 37(8), pp.852-857.

Michael S Robeson II, Devon R O'Rourke, Benjamin D Kaehler, Michal Ziemski, Matthew R Dillon, Jeffrey T Foster, Nicholas A Bokulich. (2021) RESCRIPt: Reproducible sequence taxonomy reference database management. PLoS Computational Biology 17 (11): e1009581. doi: 10.1371/journal.pcbi.1009581.

# Get sequences

The first stage in the database generation is to download the desired sequences NCBI's Genbank. This is performed with RESCRIPts function ```get-ncbi-data```:

```
source activate qiime2-2023.7

###### rbcl plant gene #######

qiime rescript get-ncbi-data \
--p-query 'rbcl[All Fields] AND 00000001000[SLEN] : 00000010000[SLEN]' \
--p-n-jobs 5 \
--o-sequences rbcl/ncbi-refseqs-unfiltered-rbcl.qza \
--o-taxonomy rbcl/ncbi-refseqs-taxonomy-unfiltered-rbcl.qza

###### 18s mollusc gene ########

qiime rescript get-ncbi-data \
--p-query '(18s[All Fields] AND ("Mollusca"[Organism] OR molluscs[All Fields])) AND 00000001000[SLEN] : 00000010000[SLEN]' \
--p-n-jobs 5 \
--o-sequences 18s-mollusca/ncbi-refseqs-unfiltered-mollusca-18s.qza \
--o-taxonomy 18s-mollusca/ncbi-refseqs-taxonomy-unfiltered-mollusca-18s.qza
```

the above script specifies the sequences required for each database using the Entrez search terms information on this can be found here https://www.ncbi.nlm.nih.gov/books/NBK3837/#EntrezHelp.Entrez_Searching_Options
The search term also specifies a minimum sequence length of 1000bp and a maximum of 10000bp, this length may be edited depending on the gene being targeted.
Please note that large downloads (>100 sequences) must be performed between on weekends or weekdays between 9 pm and 5 am US Eastern Time. 

# Curate database

There are two broad approaches for making databases for classifying sequences, one is to use the whole sequences and one is to train the classifier only on the regions targeted by your primers. Here we will build both and the example below creates the classifier for the rbcl plastid gene. 

The downloaded data will then be dereplicated but keeps identical sequences with unique taxonomic ranks (```--p-mode 'uniq'```), the classifier will handle working out the taxonomic assignment. The classifier will use the lowest common ancestor when it is unable to disambiguate very similar or identical sequences with differing taxonomy.


```
source activate qiime2-2023.7

######### dereplicate the database ##################  

qiime rescript dereplicate \
--i-sequences rbcl/ncbi-refseqs-unfiltered-rbcl.qza  \
--i-taxa rbcl/ncbi-refseqs-taxonomy-unfiltered-rbcl.qza \
--p-mode 'uniq' \
--p-threads 8 \
--o-dereplicated-sequences rbcl/basic-rbcl-ref-seqs-derep.qza \
--o-dereplicated-taxa rbcl/basic-rbcl-ref-tax-derep.qza 
```

Then ambiguous sequences are remove sequences that contain ambiguous bases that can occur (IUPAC compliant ambiguity bases) (```--p-num-degenerates 1```) and any homopolymers that are 8 or more bases in length (```--p-homopolymer-length 8```).

```
######### remove sequences with ambiguous basepairs ##################  

qiime rescript cull-seqs \
--i-sequences rbcl/basic-rbcl-ref-seqs-derep.qza \
--p-n-jobs 8 \
--p-num-degenerates 1 \
--p-homopolymer-length 8 \
--o-clean-sequences rbcl/basic-rbcl-ref-seqs-derep-cull.qza
```

The sequences and taxonomic files are then trained to create the classifier using a Naive Bayes classifier, which must be trained on the reference sequences and their taxonomic classification. This information can either consist of the entire gene sequence or the exact region your primers targeted on that genes targeted which requires your primer sequences. See this page for more information https://docs.qiime2.org/2023.7/tutorials/feature-classifier/ 
For now we will use the whole database. 

```
###############  evaluate and train classifier #############

qiime rescript evaluate-fit-classifier \
--i-sequences rbcl/basic-rbcl-ref-seqs-derep-cull.qza \
--i-taxonomy rbcl/basic-rbcl-ref-tax-derep.qza \
--p-n-jobs 2 \
--o-classifier rbcl/ncbi-rbcl-basic-refseqs-classifier.qza \
--o-evaluation rbcl/ncbi-rbcl-basic-refseqs-classifier-evaluation.qzv \
--o-observed-taxonomy rbcl/ncbi-rbcl-basic-refseqs-predicted-taxonomy.qza

```


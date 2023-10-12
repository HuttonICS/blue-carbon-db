# blue-carbon-db

This repositiory contains two Qiime2 formatted databases for examining the origins of carbon stocks from sediment along with the scripts used to create them. 
Two databases have been generated using data avalible from the NCBI, one for the plastid gene rbcl and one for 18S rRNA gene of molluscs. 

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
Create a new enviroment and install the downloaded file into that enviroment
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
Install dependancies for RESCRIPt
```
conda install -c conda-forge -c bioconda -c qiime2 -c https://packages.qiime2.org/qiime2/2023.7/tested/ -c defaults \
  xmltodict 'q2-types-genomics>2023.7' ncbi-datasets-pylib
```
Install the RESCRIPt
```
pip install git+https://github.com/bokulich-lab/RESCRIPt.git
```
Check install
```
qiime dev refresh-cache
qiime --help
```

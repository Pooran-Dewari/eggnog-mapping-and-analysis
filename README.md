# eggnog-mapping-and-analysis
```
conda create -n eggnog python=3.10 -y
conda activate eggnog
conda install -c bioconda eggnog-mapper
emapper.py -h

mkdir -p $HOME/eggnog_db

wget http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.db.gz
wget http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.taxa.tar.gz
wget http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog_proteins.dmnd.gz

gunzip *.gz
tar -xf eggnog.taxa.tar
```

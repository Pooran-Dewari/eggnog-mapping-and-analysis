# eggnog-mapping-and-analysis
```
conda create -n eggnog python=3.10 -y
conda activate eggnog
conda install -c bioconda eggnog-mapper
emapper.py -h
conda install -c bioconda -c conda-forge gffread emboss -y

mkdir -p $HOME/eggnog_db

wget http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.db.gz
wget http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog.taxa.tar.gz
wget http://eggnog5.embl.de/download/emapperdb-5.0.2/eggnog_proteins.dmnd.gz

gunzip *.gz
tar -xf eggnog.taxa.tar

GENOME=/home/pdewari/Documents/parse_2025/seurat_2025/genome/Crassostrea_gigas_uk_roslin_v1.dna_sm.primary_assembly.fa

GFF=/home/pdewari/Documents/parse_2025/seurat_2025/genome/Crassostrea_gigas.cgigas_uk_roslin_v1.58.chr.gff3

GENELIST=/home/pdewari/Documents/parse_2025/seurat_2025/cluster1_clean_genes.txt

gffread $GFF \
  -g $GENOME \
  -x cgigas_cds.fa \
  -y cgigas_proteins.fa

cat /home/pdewari/Documents/parse_2025/seurat_2025/cluster1_clean_genes.txt

seqkit grep -n -r -f $GENELIST cgigas_proteins.fa > cluster1.faa

emapper.py \
  -i cluster1.faa \
  --itype proteins \
  -m diamond \
  --cpu 8 \
  --tax_scope Metazoa \
  --target_orthologs one2one \
  --data_dir ~/eggnog_db \
  -o cluster1

```

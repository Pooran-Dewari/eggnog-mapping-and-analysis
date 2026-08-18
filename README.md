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

# ===============================
# PATHS (edit if needed)
# ===============================
GENOME=/home/pdewari/Documents/parse_2025/seurat_2025/genome/Crassostrea_gigas_uk_roslin_v1.dna_sm.primary_assembly.fa
GFF=/home/pdewari/Documents/parse_2025/seurat_2025/genome/Crassostrea_gigas.cgigas_uk_roslin_v1.58.chr.gff3
GENELIST=/home/pdewari/Documents/parse_2025/seurat_2025/cluster1_clean_genes.txt
DB=~/eggnog_db

# ===============================
# STEP 1 — generate protein FASTA
# ===============================
gffread $GFF -g $GENOME -y cgigas_proteins.fa

# ===============================
# STEP 2 — build gene → transcript → length table
# ===============================
seqkit fx2tab -n -l cgigas_proteins.fa \
| awk '{
    header=$1;
    len=$2;
    gene=header;
    sub(/transcript:/,"",gene);
    sub(/\..*/,"",gene);
    print gene"\t"len"\t"header
}' > id_len_map.txt

# ===============================
# STEP 3 — pick longest transcript per gene
# ===============================
sort -k1,1 -k2,2nr id_len_map.txt \
| awk '!seen[$1]++ {print $3}' \
> longest_ids.txt

# ===============================
# STEP 4 — create reduced proteome
# ===============================
awk '{print "^transcript:"$1"\\."}' $GENELIST > gene_patterns.txt
seqkit grep -r -f gene_patterns.txt cgigas_longest.fa > cluster1.faa

# ===============================
# STEP 5 — subset cluster1 genes
# ===============================
seqkit grep -n -r -f $GENELIST cgigas_longest.fa > cluster1.faa

# ===============================
# STEP 6 — sanity check
# ===============================
echo "Number of sequences in cluster1.faa:"
grep '>' -c cluster1.faa

echo "Number of input genes:"
wc -l $GENELIST

# ===============================
# STEP 7 — run eggNOG
# ===============================
emapper.py \
  -i cluster1.faa \
  --itype proteins \
  -m diamond \
  --cpu 8 \
  --tax_scope Metazoa \
  --target_orthologs one2one \
  --data_dir $DB \
  -o cluster1_clean

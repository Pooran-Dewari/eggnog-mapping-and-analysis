#!/bin/bash
#$ -V -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=16G
#$ -pe sharedmem 16

set -euo pipefail

# =========================================================
# PROJECT PATHS
# =========================================================
PROJECT="/exports/cmvm/eddie/eb/groups/bean_grp/Pooran/eggnog"

DB="$PROJECT/eggnog_db"
INPUT="$PROJECT/input"
RESULTS="$PROJECT/results"

FASTA="$INPUT/cluster1.faa"

# =========================================================
# CONDA (HPC SAFE FOR EDDIE)
# =========================================================
set +u
source /exports/applications/apps/SL7/anaconda/5.3.1/etc/profile.d/conda.sh
conda activate eggnog
set -u
# =========================================================
# TIMESTAMPED OUTPUT DIRECTORY
# =========================================================
TS=$(date +"%Y%m%d_%H%M%S")
OUT="$RESULTS/cluster1_$TS"
LOGDIR="$OUT/logs"

mkdir -p "$OUT" "$LOGDIR"

# =========================================================
# ARCHIVE SCRIPT + ENVIRONMENT (REPRODUCIBILITY)
# =========================================================
cp "$0" "$OUT/run_script.sh"
env > "$OUT/env.txt"

# =========================================================
# REDIRECT ALL OUTPUT TO LOG FILES
# =========================================================
exec > >(tee -a "$LOGDIR/stdout.log") 2> >(tee -a "$LOGDIR/stderr.log" >&2)

echo "========================================"
echo "EggNOG RUN STARTED"
echo "Time   : $(date)"
echo "Input  : $FASTA"
echo "Output : $OUT"
echo "DB     : $DB"
echo "========================================"

# =========================================================
# RUN EGNNOG-MAPPER
# =========================================================
emapper.py \
  -i "$FASTA" \
  --itype proteins \
  -m diamond \
  --cpu 16 \
  --tax_scope Metazoa \
  --target_orthologs one2one \
  --data_dir "$DB" \
  -o "$OUT/cluster1_clean"

# =========================================================
# FINAL SUMMARY
# =========================================================
echo "========================================"
echo "EggNOG RUN COMPLETED"
echo "Time   : $(date)"
echo "Results:"
ls -lh "$OUT"
echo "Logs:"
ls -lh "$LOGDIR"
echo "========================================"

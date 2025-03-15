#!/usr/bin/zsh
#SBATCH --time=01:00:00
#SBATCH --account=lect0138
#SBATCH --partition=c23g
#SBATCH --reservation=PPCES-g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --gres=gpu:1

###############################################################################
# Usage:
#   1) Make sure flexynesis is installed in your conda env (or Python env).
#   2) Modify paths (DATA_PATH, etc.) to match your environment.
#   3) Submit this script with: sbatch run_flexynesis_benchmark.sh
###############################################################################

# (Optional) Load your HPC modules here. Example:
# module load Miniconda3
# conda activate flexynesisenv

# Data and output paths
DATA_PATH="/home/thesamurai/sciebo/Project_Allocation/module3_trial_multiomics/compgen_course_2025_module3_my_session/submissions/day3/ccle_vs_gdsc/"
OUTPUT_DIR="logs_flexynesis"
mkdir -p "$OUTPUT_DIR"

# Target variable for drug response
TARGET_VARIABLE="Erlotinib"

# Hyperparameter optimization steps
HPO_ITER=15

# Feature filtering thresholds (example)
FEATURES_TOP_PERCENTILE=10
VARIANCE_THRESHOLD=1

# Model classes (non-GNN)
NON_GNN_CLASSES=("DirectPred" "supervised_vae")

# GNN-specific conv types
GNN_CONV_TYPES=("GC" "SAGE")

# Data-type combos (3 combos → 3 x 2 fusion for non-GNN = 6 runs each class; for GNN: 3 combos x 2 conv types = 6 runs)
DATA_TYPE_LIST=(
  "mut"
  "mut,cna"
  "mut,rna"
)

# Two fusion modes for non-GNN
FUSION_MODES=(
  "early"
  "intermediate"
)

echo "================================================================"
echo "Starting Flexynesis HPC runs for Erlotinib (CCLE vs GDSC)"
echo "================================================================"

############################################
# 1) Non-GNN runs: DirectPred or supervised_vae
############################################
for MODEL_CLASS in "${NON_GNN_CLASSES[@]}"; do
  for DATA_COMBO in "${DATA_TYPE_LIST[@]}"; do
    for FUSION_TYPE in "${FUSION_MODES[@]}"; do

      echo "-----------------------------------------------------------"
      echo "Model: $MODEL_CLASS | Data: $DATA_COMBO | Fusion: $FUSION_TYPE"
      echo "-----------------------------------------------------------"

      srun --gres=gpu:1 flexynesis \
        --use_gpu \
        --data_path "$DATA_PATH" \
        --model_class "$MODEL_CLASS" \
        --data_types "$DATA_COMBO" \
        --target_variables "$TARGET_VARIABLE" \
        --fusion "$FUSION_TYPE" \
        --hpo_iter "$HPO_ITER" \
        --features_top_percentile "$FEATURES_TOP_PERCENTILE" \
        --variance_threshold "$VARIANCE_THRESHOLD" \
        --output_path "$OUTPUT_DIR" \
        > "${OUTPUT_DIR}/run_${MODEL_CLASS}_${DATA_COMBO}_${FUSION_TYPE}.log" 2>&1

    done
  done
done

############################################
# 2) GNN runs: only early fusion, vary gnn_conv_type
############################################
MODEL_CLASS="GNN"
for DATA_COMBO in "${DATA_TYPE_LIST[@]}"; do
  for CONV_TYPE in "${GNN_CONV_TYPES[@]}"; do

    echo "-----------------------------------------------------------"
    echo "Model: $MODEL_CLASS | Data: $DATA_COMBO | gnn_conv_type=$CONV_TYPE"
    echo "-----------------------------------------------------------"

    srun --gres=gpu:1 flexynesis \
      --use_gpu \
      --data_path "$DATA_PATH" \
      --model_class "$MODEL_CLASS" \
      --gnn_conv_type "$CONV_TYPE" \
      --data_types "$DATA_COMBO" \
      --target_variables "$TARGET_VARIABLE" \
      --fusion early \
      --hpo_iter "$HPO_ITER" \
      --features_top_percentile "$FEATURES_TOP_PERCENTILE" \
      --variance_threshold "$VARIANCE_THRESHOLD" \
      --output_path "$OUTPUT_DIR" \
      > "${OUTPUT_DIR}/run_${MODEL_CLASS}_${DATA_COMBO}_${CONV_TYPE}.log" 2>&1

  done
done

echo "================================================================"
echo "All 18 Flexynesis runs completed."
echo "Logs are in the '$OUTPUT_DIR' directory."
echo "================================================================"

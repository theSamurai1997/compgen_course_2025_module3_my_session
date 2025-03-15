#!/usr/bin/env bash
#
# run_flexynesis_local.sh
# A local script to benchmark multiple Flexynesis runs (18 total),
# saving best model checkpoints and addressing HPC/log insights.
# 
# SYSTEM INFO (as provided):
#   CPU(s): 12
#   Vendor ID: GenuineIntel
#   Model name: 13th Gen Intel(R) Core(TM) i7-1365U
#   Thread(s) per core: 2
#   Core(s) per socket: 10
#   ...
#
# Usage:
#   1) Make executable: chmod +x run_flexynesis_local.sh
#   2) Run it:          ./run_flexynesis_local.sh
#
# Adjust variables below (DATA_PATH, target variable, HPO_ITER, etc.)
# to fit your local environment and data paths.

#########################
# User-defined settings #
#########################

DATA_PATH="/home/thesamurai/sciebo/Project_Allocation/module3_trial_multiomics/compgen_course_2025_module3_my_session/submissions/day3/ccle_vs_gdsc/"
TARGET_VARIABLE="Erlotinib"    # Name of drug response variable in clin.csv
HPO_ITER=15                   # Number of HPO iterations (example: 15)
FEATURES_PERCENTILE=10        # Keep top 10% features (example)
VAR_THRESHOLD=0.5               # Remove lowest 0.5 % variable features

# Since this system has 12 total CPU(s), let's allocate up to 12 threads
THREADS=12
# We'll use 6 or 8 as a moderate number for DataLoader workers; let's pick 6
NUM_WORKERS=6

#########################
# Model configurations  #
#########################

# Output directory for logs/results
OUTPUT_DIR="logs_flexynesis"
mkdir -p "${OUTPUT_DIR}"

# Different data modality combinations
DATA_TYPE_LIST=(
  "mutation"
  "rna"
  "cnv"
  "mutation,cnv"
  "mutation,rna"
  "rna,cnv"
)

# Two fusion types for non-GNN models
FUSION_MODES=(
  "early"
  "intermediate"
)

# Non-GNN model classes
NON_GNN_CLASSES=("DirectPred" "supervised_vae")

# GNN model class and convolution types
GNN_CLASS="GNN"
GNN_CONV_TYPES=("GC" "SAGE")

#########################
# Script body
#########################

echo "================================================================"
echo "Running Flexynesis locally for Erlotinib (CCLE vs GDSC)"
echo "Data path:         $DATA_PATH"
echo "Target variable:   $TARGET_VARIABLE"
echo "HPO iterations:    $HPO_ITER"
echo "================================================================"

#################################################
# 1) Non-GNN runs: DirectPred or supervised_vae
#################################################
for MODEL_CLASS in "${NON_GNN_CLASSES[@]}"; do
  for DATA_COMBO in "${DATA_TYPE_LIST[@]}"; do
    for FUSION_TYPE in "${FUSION_MODES[@]}"; do
      # Build a unique prefix so that each run's best model is saved separately
      PREFIX="run_${MODEL_CLASS}_${DATA_COMBO}_${FUSION_TYPE}"

      echo "-----------------------------------------------------------"
      echo "Model: $MODEL_CLASS | Data: $DATA_COMBO | Fusion: $FUSION_TYPE"
      echo "Saving under prefix: $PREFIX"
      echo "-----------------------------------------------------------"

      flexynesis \
        --data_path "$DATA_PATH" \
        --model_class "$MODEL_CLASS" \
        --data_types "$DATA_COMBO" \
        --target_variables "$TARGET_VARIABLE" \
        --fusion_type "$FUSION_TYPE" \
        --hpo_iter "$HPO_ITER" \
        --features_top_percentile "$FEATURES_PERCENTILE" \
        --variance_threshold "$VAR_THRESHOLD" \
        --prefix "$PREFIX" \
        --outdir "$OUTPUT_DIR" \
        > "${OUTPUT_DIR}/${PREFIX}.log" 2>&1
    done
  done
done

##################################################
# 2) GNN runs: only early fusion, vary gnn_conv_type
##################################################
for DATA_COMBO in "${DATA_TYPE_LIST[@]}"; do
  for CONV_TYPE in "${GNN_CONV_TYPES[@]}"; do
    PREFIX="run_${GNN_CLASS}_${DATA_COMBO}_${CONV_TYPE}"

    echo "-----------------------------------------------------------"
    echo "Model: $GNN_CLASS | Data: $DATA_COMBO | gnn_conv_type=$CONV_TYPE (fusion=early)"
    echo "Saving under prefix: $PREFIX"
    echo "-----------------------------------------------------------"

    flexynesis \
      --data_path "$DATA_PATH" \
      --model_class "$GNN_CLASS" \
      --gnn_conv_type "$CONV_TYPE" \
      --data_types "$DATA_COMBO" \
      --target_variables "$TARGET_VARIABLE" \
      --fusion_type early \
      --hpo_iter "$HPO_ITER" \
      --features_top_percentile "$FEATURES_PERCENTILE" \
      --variance_threshold "$VAR_THRESHOLD" \
      --prefix "$PREFIX" \
      --outdir "$OUTPUT_DIR" \
      > "${OUTPUT_DIR}/${PREFIX}.log" 2>&1
  done
done

echo "================================================================"
echo "All 36 Flexynesis runs completed."
echo "Total: 24 (non-GNN) + 12 (GNN) = 36"
echo "Logs and best models are saved under '$OUTPUT_DIR'."
echo "================================================================"
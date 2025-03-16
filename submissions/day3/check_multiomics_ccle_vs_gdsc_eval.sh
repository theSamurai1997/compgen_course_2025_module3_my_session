#!/usr/bin/env bash
#
# run_flexynesis_local.sh
# A local script to benchmark multiple Flexynesis runs (36 total) and skip reruns if files are present.
#
# The system has 12 CPU cores. We'll use 12 threads and 6 DataLoader workers by default.
#
# Usage:
#   1) Make executable: chmod +x run_flexynesis_local.sh
#   2) Run it:          ./run_flexynesis_local.sh
#
# Adjust variables below (DATA_PATH, target variable, HPO_ITER, etc.) to fit your environment.

#########################
# User-defined settings #
#########################

DATA_PATH="/home/thesamurai/sciebo/Project_Allocation/module3_trial_multiomics/compgen_course_2025_module3_my_session/submissions/day3/ccle_vs_gdsc/"
TARGET_VARIABLE="Erlotinib"   # Name of drug response variable in clin.csv
HPO_ITER=15                   # Number of HPO iterations
FEATURES_PERCENTILE=10        # Keep top 10% of features
VAR_THRESHOLD=0.5             # Remove the lowest 0.5% of variable features

THREADS=12
NUM_WORKERS=6

# Output directory
OUTPUT_DIR="logs_flexynesis"
mkdir -p "${OUTPUT_DIR}"

# Data combos
DATA_TYPE_LIST=(
  "mutation"
  "rna"
  "cnv"
  "mutation,cnv"
  "mutation,rna"
  "rna,cnv"
)

# Fusion modes (for non-GNN)
FUSION_MODES=(
  "early"
  "intermediate"
)

# Non-GNN model classes
NON_GNN_CLASSES=("DirectPred" "supervised_vae")

# GNN model & conv types
GNN_CLASS="GNN"
GNN_CONV_TYPES=("GC" "SAGE")

# Required output files. 
# We'll look in $OUTPUT_DIR/$PREFIX/ for each of these: $PREFIX<EXT>
REQUIRED_EXTS=(
  ".final_model.pth"
  ".stats.csv"
  ".predicted_labels.csv"
  ".feature_importance.IntegratedGradients.csv"
  ".embeddings_test.csv"
  ".embeddings_train.csv"
)

#########################
# Helper function
#########################
function all_files_exist() {
  # $1 => the prefix
  local prefix="$1"
  local prefix_dir="${OUTPUT_DIR}/${prefix}"
  
  for ext in "${REQUIRED_EXTS[@]}"; do
    # Typically Flexynesis naming is "<prefix><extension>"
    # e.g. run_DirectPred_mutation_early.final_model.pth
    # We check if the file exists in the subdirectory 
    # or directly in the outdir. 
    # Adjust if your flexynesis actually places them inside prefix_dir 
    # with the same <prefix> name.
    
    local fullpath="${prefix_dir}/${prefix}${ext}"
    if [[ ! -f "$fullpath" ]]; then
      # If any file is missing, return 1 (false)
      return 1
    fi
  done
  
  # If all files are found
  return 0
}

#########################
# Script body
#########################

echo "================================================================"
echo "Running Flexynesis for Erlotinib (CCLE vs GDSC) with skipping if present"
echo "Data path:         $DATA_PATH"
echo "Target variable:   $TARGET_VARIABLE"
echo "HPO iterations:    $HPO_ITER"
echo "Threads:           $THREADS"
echo "Num workers:       $NUM_WORKERS"
echo "================================================================"


#################################################
# 1) Non-GNN runs
#################################################
for MODEL_CLASS in "${NON_GNN_CLASSES[@]}"; do
  for DATA_COMBO in "${DATA_TYPE_LIST[@]}"; do
    for FUSION_TYPE in "${FUSION_MODES[@]}"; do
      PREFIX="run_${MODEL_CLASS}_${DATA_COMBO}_${FUSION_TYPE}"
      PREFIX_DIR="${OUTPUT_DIR}/${PREFIX}"

      echo "-----------------------------------------------------------"
      echo "Model: $MODEL_CLASS | Data: $DATA_COMBO | Fusion: $FUSION_TYPE"
      echo "Prefix: $PREFIX"
      echo "-----------------------------------------------------------"
      
      # Check if subdir exists and required files are present
      if [[ -d "$PREFIX_DIR" ]]; then
        echo "Checking if all required files exist for $PREFIX ..."
        if all_files_exist "$PREFIX"; then
          echo "All output files found for $PREFIX. Skipping."
          echo "-----------------------------------------------------------"
          continue
        else
          echo "Some files missing for $PREFIX. Will run flexynesis."
        fi
      fi
      
      mkdir -p "$PREFIX_DIR"
      
      flexynesis \
        --threads "$THREADS" \
        --num_workers "$NUM_WORKERS" \
        --data_path "$DATA_PATH" \
        --model_class "$MODEL_CLASS" \
        --data_types "$DATA_COMBO" \
        --target_variables "$TARGET_VARIABLE" \
        --fusion_type "$FUSION_TYPE" \
        --hpo_iter "$HPO_ITER" \
        --features_top_percentile "$FEATURES_PERCENTILE" \
        --variance_threshold "$VAR_THRESHOLD" \
        --prefix "$PREFIX" \
        --outdir "$PREFIX_DIR" \
        > "${OUTPUT_DIR}/${PREFIX}.log" 2>&1
    done
  done
done

##################################################
# 2) GNN runs (fusion=early), vary gnn_conv_type
##################################################
for DATA_COMBO in "${DATA_TYPE_LIST[@]}"; do
  for CONV_TYPE in "${GNN_CONV_TYPES[@]}"; do
    PREFIX="run_${GNN_CLASS}_${DATA_COMBO}_${CONV_TYPE}"
    PREFIX_DIR="${OUTPUT_DIR}/${PREFIX}"

    echo "-----------------------------------------------------------"
    echo "Model: $GNN_CLASS | Data: $DATA_COMBO | gnn_conv_type=$CONV_TYPE"
    echo "Prefix: $PREFIX"
    echo "-----------------------------------------------------------"
    
    if [[ -d "$PREFIX_DIR" ]]; then
      echo "Checking if all required files exist for $PREFIX ..."
      if all_files_exist "$PREFIX"; then
        echo "All output files found for $PREFIX. Skipping."
        echo "-----------------------------------------------------------"
        continue
      else
        echo "Some files missing for $PREFIX. Will run flexynesis."
      fi
    fi
    
    mkdir -p "$PREFIX_DIR"
    
    flexynesis \
      --threads "$THREADS" \
      --num_workers "$NUM_WORKERS" \
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
      --outdir "$PREFIX_DIR" \
      > "${OUTPUT_DIR}/${PREFIX}.log" 2>&1
  done
done

echo "================================================================"
echo "All 36 Flexynesis runs completed or skipped if previously found."
echo "Total: 24 (non-GNN) + 12 (GNN) = 36"
echo "Logs and best models are saved under '$OUTPUT_DIR'."
echo "This script is designed by Dr. Karan Kumar, Postdoc at Institute of"
echo "Applied Microbiology, RWTH Aachen University, Germany."
echo "Dr. Kumar Acknowledges compgen2025 module organized by Dr. Bora."
echo "================================================================"

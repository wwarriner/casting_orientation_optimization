#!/bin/bash
SHELL_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SHELL_DIR/../../../..")
PATH=$PATH:"$ROOT_DIR"
COMPONENT_NAME=$1

REPOS_DIR=$ROOT_DIR'/repos'
OUTPUT_DIR=$ROOT_DIR'/oo_results'

# Toolsuite
CGT_DIR=$REPOS_DIR'/casting_geometric_toolsuite'

# Orientation Optimization Analysis
COO_DIR=$REPOS_DIR'/casting_orientation_optimization'
SETTINGS_FILE=$COO_DIR'/src/data_extraction/extraction_settings.json'

BASE_CASE_PATH=$ROOT_DIR'/oo_data/'$COMPONENT_NAME'_base_case.mat'

TIME=$(date +%s%N)
OUTPUT_BASE_PATH=$ROOT_DIR'/oo_results/'$COMPONENT_NAME
OUTPUT_PATH=$OUTPUT_BASE_PATH'_'$TIME
mkdir -p $OUTPUT_PATH

# MATLAB
RECIPE_CLASS='DefaultRecipe'
RUN_CMD='addpath( genpath( '\'$CGT_DIR\'' ) );addpath( genpath( '\'$COO_DIR\'' ) );generate_data_on_hpc( '\'$BASE_CASE_PATH\'', '\'$RECIPE_CLASS\'', [$ANGLES], $SLURM_ARRAY_TASK_ID, $SLURM_ARRAY_JOB_ID, '\'$OUTPUT_PATH\'' );exit;'
printf "%s\n" $FULL_CMD

CSV_NAME='sphere_angles.csv'
CSV_PATH=$ROOT_DIR'/'$CSV_NAME
NAME=oo_project
ARRAYMAX=$(( $( wc -l < $CSV_PATH ) -1 ))
MAXTASKS=256
TASKS=1
MEMORY='20GB'
TIME=2:00:00
PARTITION=express
MAILTYPE=FAIL
MAILADDRESS='wwarr@uab.edu'

#0-$ARRAYMAX
sbatch --array=0-$ARRAYMAX%$MAXTASKS --job-name $NAME --output=$ROOT_DIR/output/output_%A_%a.txt --ntasks=$TASKS --mem-per-cpu=$MEMORY --time=$TIME --partition=$PARTITION --mail-type=$MAILTYPE --mail-user=$MAILADDRESS <<LIMITING_STRING
#!/bin/bash
module load rc/matlab/R2019a
ANGLES=\$( sed \$(( \$SLURM_ARRAY_TASK_ID+1 ))'q;d' $CSV_PATH )
echo "\$ANGLES"
matlab -nodesktop -nodisplay -sd "$REPOS_DIR" -r "$RUN_CMD"
LIMITING_STRING

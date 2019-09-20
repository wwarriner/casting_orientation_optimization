#!/bin/bash
SHELL_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SHELL_DIR/../../../..")
PATH=$PATH:"$ROOT_DIR"
COMPONENT_NAME=$1

REPOS_DIR=$ROOT_DIR'/repos'
OUTPUT_DIR=$ROOT_DIR'/oo_results'

# Toolsuite
CGT_DIR=$REPOS_DIR'/casting_geometric_toolsuite'
if [ ! -d "$CGT_DIR" ]; then
	printf "Can't locate CGT_DIR: %s\n" $CGT_DIR
	exit
fi

# Orientation Optimization Analysis
COO_DIR=$REPOS_DIR'/casting_orientation_optimization'
if [ ! -d "$COO_DIR" ]; then
	printf "Can't locate COO_DIR: %s\n" $COO_DIR
	exit
fi
DATA_EXTRACTION_DIR=$COO_DIR'/src/data_extraction'
SETTINGS_FILE=$DATA_EXTRACTION_DIR'/extraction_settings.json'
if [ ! -f "$SETTINGS_FILE" ]; then
	printf "Can't locate COO extraction settings JSON file: %s\n" $SETTINGS_FILE
	exit
fi
ANGLES_FILE=$DATA_EXTRACTION_DIR'/sphere_angles.csv'
if [ ! -f "$ANGLES_FILE" ]; then
	printf "Can't locate COO angles CSV file: %s\n" $ANGLES_FILE
	printf "Run sphere_angles.m in MATLAB to generate.\n"
	exit
fi
ANGLES_COUNT=$(( $( wc -l < $ANGLES_FILE ) -1 ))

BASE_CASE_FILE=$ROOT_DIR'/oo_data/'$COMPONENT_NAME'.obc'
if [ ! -f "$BASE_CASE_FILE" ]; then
	printf "Can't locate base case MAT file: %s\n" $BASE_CASE_FILE
	printf "Run oo_base_cases.sh first to generate.\n"
	exit
fi

TIME=$(date +%s%N)
OUTPUT_BASE_PATH=$ROOT_DIR'/oo_results/'$COMPONENT_NAME
OUTPUT_PATH=$OUTPUT_BASE_PATH'_$SLURM_ARRAY_JOB_ID_'$TIME
mkdir -p $OUTPUT_PATH
if [ ! -d "$OUTPUT_PATH" ]; then
	printf "Can't locate OUTPUT_PATH: %s\n" $OUTPUT_PATH
	exit
fi

LOGGING_PATH=$ROOT_DIR'/output_'$TIME
mkdir -p $LOGGING_PATH
if [ ! -d "$LOGGING_PATH" ]; then
	printf "Can't locate LOGGING_PATH: %s\n" $LOGGING_PATH
	exit
fi

# MATLAB
RECIPE_CLASS='DefaultRecipe'
RECIPE_CLASS_FILE=$DATA_EXTRACTION_DIR'/'$RECIPE_CLASS'.m'
if [ ! -f "$RECIPE_CLASS_FILE" ]; then
	printf "Can't locate recipe M file: %s\n" $RECIPE_CLASS_FILE
	exit
fi
RUN_CMD='addpath( genpath( '\'$CGT_DIR\'' ) );addpath( genpath( '\'$COO_DIR\'' ) );generate_data_on_hpc( '\'$BASE_CASE_FILE\'', '\'$RECIPE_CLASS\'', [$ANGLES], $SLURM_ARRAY_TASK_ID, $SLURM_ARRAY_JOB_ID, $OUTPUT_PATH );exit;'

NAME=oo_project
ARRAYMAX=$ANGLES_COUNT
MAXTASKS=256
TASKS=1
MEMORY='20GB'
TIME=2:00:00
PARTITION=express
MAILTYPE=FAIL
MAILADDRESS='wwarr@uab.edu'

#0-$ARRAYMAX
sbatch --array=0-$ARRAYMAX%$MAXTASKS --job-name $NAME --output=$LOGGING_PATH/output_%A_%a.txt --ntasks=$TASKS --mem-per-cpu=$MEMORY --time=$TIME --partition=$PARTITION --mail-type=$MAILTYPE --mail-user=$MAILADDRESS <<LIMITING_STRING
#!/bin/bash
module load rc/matlab/R2019a
ANGLES=\$( sed \$(( \$SLURM_ARRAY_TASK_ID+1 ))'q;d' $ANGLES_FILE )
echo "\$ANGLES"
matlab -nodesktop -nodisplay -sd "$REPOS_DIR" -r "$RUN_CMD"
LIMITING_STRING

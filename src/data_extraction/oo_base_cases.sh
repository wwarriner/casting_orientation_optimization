#!/bin/bash
SHELL_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SHELL_DIR/../../../..")
PATH=$PATH:"$ROOT_DIR"

STL_FOLDER=$ROOT_DIR'/oo_stl'
if [ ! -d "$STL_FOLDER" ]; then
	printf "Can't locate STL_FOLDER: %s\n" $STL_FOLDER
	exit
fi
shopt -s nocaseglob
STL_PATHS=()
for filename in $STL_FOLDER/*.stl; do
    printf "%s\n" $filename
	STL_PATHS+=("$filename")
done
STL_PATH_COUNT=${#STL_PATHS[@]}
if (( $STL_PATH_COUNT <= 0 )); then
	printf "Didn't find any STL files in %s\n" $STL_FOLDER
	exit
fi

REPOS_DIR=$ROOT_DIR'/repos'
OUTPUT_DIR=$ROOT_DIR'/oo_data'
mkdir -p $OUTPUT_DIR
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
SETTINGS_FILE=$COO_DIR'/src/data_extraction/extraction_settings.json'
if [ ! -f "$SETTINGS_FILE" ]; then
	printf "Can't locate COO extraction settings JSON file: %s\n" $SETTINGS_FILE
	exit
fi

# MATLAB
RUN_CMD='addpath( genpath( '\'$CGT_DIR\'' ) );addpath( genpath( '\'$COO_DIR\'' ) );generate_base_case_data( '\'$SETTINGS_FILE\'', '\''$STL_PATH'\'', '\'$OUTPUT_DIR\'' );exit;'

NAME=oo_project
ARRAYMAX=$(( array_max=$STL_PATH_COUNT-1 ))
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
PATHS=(${STL_PATHS[@]})
STL_PATH=\${PATHS[\$SLURM_ARRAY_TASK_ID]}
echo "\$STL_PATH"
matlab -nodesktop -nodisplay -sd "$REPOS_DIR" -r "$RUN_CMD"
LIMITING_STRING

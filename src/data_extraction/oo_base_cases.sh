#!/bin/bash
SHELL_DIR=$(dirname "$(realpath "$0")")
ROOT_DIR=$(realpath "$SHELL_DIR/../../../..")
PATH=$PATH:"$ROOT_DIR"

# get array of all stls in folder
STL_FOLDER_PATH=$ROOT_DIR'/oo_stl'
shopt -s nocaseglob
STL_PATHS=()
for filename in $STL_FOLDER_PATH/*.stl; do
    echo "$filename"
	STL_PATHS+=("$filename")
done
STL_PATH_COUNT=${#STL_PATHS[@]}


REPOS_DIR=$ROOT_DIR'/repos'
OUTPUT_DIR=$ROOT_DIR'/oo_data'

# Toolsuite
CGT_DIR=$REPOS_DIR'/casting_geometric_toolsuite'

# Orientation Optimization Analysis
COO_DIR=$REPOS_DIR'/casting_orientation_optimization'
SETTINGS_FILE=$COO_DIR'/src/data_extraction/extraction_settings.json'

# MATLAB
RUN_CMD='addpath( genpath( '\'$CGT_DIR\'' ) );addpath( genpath( '\'$COO_DIR\'' ) );generate_base_case_data( '\'$SETTINGS_FILE\'', '\''$STL_PATH'\'', '\'$OUTPUT_DIR\'' );exit;'
printf "%s\n" $FULL_CMD

NAME=oo_project
ARRAYMAX=$(( array_max=$STL_PATH_COUNT-1 ))
MAXTASKS=256
TASKS=1
MEMORY='20GB'
TIME=2:00:00
PARTITION=express
PARTITION=short
MAILTYPE=FAIL
MAILADDRESS='wwarr@uab.edu'

#0-$ARRAYMAX
sbatch --array=0-$ARRAYMAX%$MAXTASKS --job-name $NAME --output=$ROOT_DIR/output/output_%A_%a.txt --ntasks=$TASKS --mem-per-cpu=$MEMORY --time=$TIME --partition=$PARTITION --mail-type=$MAILTYPE --mail-user=$MAILADDRESS <<LIMITING_STRING
#!/bin/bash
module load rc/matlab/R2019a
PATHS=(${STL_PATHS[@]})
STL_PATH=\${PATHS[\$SLURM_ARRAY_TASK_ID]}
echo "\$STL_PATH"
matlab -nodesktop -nodisplay -sd "$REPOS_DIR" -r "$RUN_CMD"
LIMITING_STRING

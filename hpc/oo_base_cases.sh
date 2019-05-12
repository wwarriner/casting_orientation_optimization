#!/bin/bash
ROOT_DIR=$(dirname "$(realpath "$0")")
PATH=$PATH:"$ROOT_DIR"

# get array of all stls in folder
STL_PATH=$ROOT_DIR/oo_stl
shopt -s nocaseglob
STL_PATHS=()
for filename in $STL_PATH/*.stl; do
	STL_PATHS+=("$filename")
done
STL_PATH_COUNT=${#STL_PATHS[@]}

REPO_DIR=$ROOT_DIR'/repos'
OUTPUT_DIR=$ROOT_DIR'/oo_component_data'
CGT_DIR=$ROOT_DIR'/repos/casting_geometric_toolsuite'
OPTION_DIR=$CGT_DIR'/examples/hpc_batch_demo/res/hpc_batch_demo_options.json'
RUN_CMD='generate_base_case_data( '\'$OPTION_DIR\'', '\''$STL_PATH'\'', '\'$OUTPUT_DIR\'' );'
FULL_CMD=$( create_matlab_command -a -c $REPO_DIR -d $ROOT_DIR -f "$RUN_CMD" )
printf "%s\n" "$FULL_CMD"

NAME=ict_project
ARRAYMAX=$(( array_max=$STL_PATH_COUNT-1 ))
MAXTASKS=1
TASKS=1
MEMORY='20GB'
TIME=2:00:00
PARTITION=express
MAILTYPE=FAIL
MAILADDRESS='wwarr@uab.edu'

module load rc/matlab/R2018a
sbatch --array=0-$ARRAYMAX%$MAXTASKS --job-name $NAME --output=output/output_%A_%a.txt --ntasks=$TASKS --mem-per-cpu=$MEMORY --time=$TIME --partition=$PARTITION --mail-type=$MAILTYPE --mail-user=$MAILADDRESS <<LIMITING_STRING
#!/bin/bash
STL_PATH=${STL_PATHS[$SLURM_ARRAY_TASK_ID]}
matlab -nodisplay -nodesktop -nojvm -sd $ROOT_DIR -r $FULL_CMD
LIMITING_STRING

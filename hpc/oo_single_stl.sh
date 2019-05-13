#!/bin/bash
ROOT_DIR=$(dirname "$(realpath "$0")")
PATH=$PATH:"$ROOT_DIR"
COMPONENT_NAME=$1

REPO_DIR=$ROOT_DIR'/repos'
OO_DIR=$REPO_DIR'/casting_orientation_optimization'
RES_DIR=$OO_DIR'/res'
COMPONENT_PATH=$ROOT_DIR'/oo_component_data/'$COMPONENT_NAME'_Component.mat'
FEEDERS_PATH=$ROOT_DIR'/oo_component_data/'$COMPONENT_NAME'_Feeders.mat'
OPTIONS_NAME='oo_options.json'
OPTIONS_PATH=$RES_DIR'/'$OPTIONS_NAME
OBJECTIVE_NAME='objective_variables.json'
OBJECTIVE_PATH=$RES_DIR'/'$OBJECTIVE_NAME
TIME=$(date +%s%N)
OUTPUT_BASE_PATH=$ROOT_DIR'/oo_results/'$COMPONENT_NAME
OUTPUT_PATH=$OUTPUT_BASE_PATH'_'$TIME
mkdir -p $OUTPUT_PATH
RUN_CMD='generate_csvs_on_hpc( '\'$COMPONENT_PATH\'', '\'$FEEDERS_PATH\'', '\'$OPTIONS_PATH\'', '\'$OBJECTIVE_PATH\'', [$ANGLES], $SLURM_ARRAY_TASK_ID, $SLURM_JOB_ID, '\'$OUTPUT_PATH\'' );'
FULL_CMD=$( create_matlab_command -a -c $REPO_DIR -d $ROOT_DIR -f "$RUN_CMD" )

CSV_NAME='sphere_angles.csv'
CSV_PATH=$ROOT_DIR'/'$CSV_NAME
NAME=oo_project
ARRAYMAX=$(( $( wc -l < $CSV_PATH ) -1 ))
MAXTASKS=1
TASKS=1
MEMORY='20GB'
TIME=2:00:00
PARTITION=express
MAILTYPE=FAIL
MAILADDRESS='wwarr@uab.edu'

module load rc/matlab/R2018a
JOB_ID=$( sbatch --array=0-$ARRAYMAX%$MAXTASKS --job-name=$NAME --output=output/output_%A_%a.txt --ntasks=$TASKS --mem-per-cpu=$MEMORY --time=$TIME --partition=$PARTITION --mail-type=$MAILTYPE --mail-user=$MAILADDRESS <<LIMITING_STRING
#!/bin/bash
ANGLES=\$( sed \$(( \$SLURM_ARRAY_TASK_ID+1 ))'q;d' $CSV_PATH )
matlab -nodisplay -nodesktop -sd $ROOT_DIR -r $FULL_CMD
LIMITING_STRING
)
JOB_ID=${JOB_ID##* }
printf '%s\n' "$JOB_ID"

copy_file()
{
	DIR=`dirname "$1"`
	BASENAME=`basename "$1"`
	EXT=".${BASENAME##*.}"
	NAME="${BASENAME%.*}"
	
	OUT_DIR="$2"
	JOB_ID="$3"
	CP_PATH="$OUT_DIR"'/'"$NAME"'_'"$JOB_ID""$EXT"
	cp -fp "$1" "$CP_PATH"
}

copy_file "$OBJECTIVE_PATH" "$OUTPUT_PATH" "$JOB_ID"
copy_file "$COMPONENT_PATH" "$OUTPUT_PATH" "$JOB_ID"
copy_file "$FEEDERS_PATH" "$OUTPUT_PATH" "$JOB_ID"
copy_file "$CSV_PATH" "$OUTPUT_PATH" "$JOB_ID"
copy_file "$OPTIONS_PATH" "$OUTPUT_PATH" "$JOB_ID"

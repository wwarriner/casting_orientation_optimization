#!/bin/bash
ROOT_DIR=$(dirname "$(realpath "$0")")
PATH=$PATH:"$ROOT_DIR"

# get array of all stls in folder
STL_PATH=$ROOT_DIR/oo_stl
shopt -s nocaseglob
for filename in $STL_PATH/*.stl; do
	BASE=$(basename "${filename%.*}")
	./oo_single_stl.sh "$BASE" 
done

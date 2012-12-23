#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_commands.sh

## REM : required includes are in main file



CVM_COMMANDS_print_status()
{
	echo "++++   C++ Version Manager   ++++"
	echo "* version            : $CVM_VERSION"
	echo "* stamp              : $(stat -c %y "$OSL_INIT_script_full_path")"
#	echo "* compset count      : [TODO]"
	echo "* default data dir   : $CVM_DEFAULT_DATA_DIR"
	echo "* current data dir   : $CVM_DATA_DIR"
	echo "* component sets dir : $CVM_COMPSETS_DIR"
	echo "* current compset    : \"`cat \"$CVM_ACTIVE_COMPSET\"`\""
	echo "* current compset components :"
	CVM_COMP_SELECTION_dump
}

CVM_COMMANDS_list_compsets()
{
	echo "Currently available C++VM components sets :"
	## note : since we ensure a default compset, there will always be at last one
	for compset_dir in $(find "$CVM_COMPSETS_DIR" -mindepth 1 -maxdepth 1 -type d -print); do
		echo "  $(basename $compset_dir)"
	done
}

#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source cvm_lib_commands.sh

## REM : required includes are in main file



CVM_COMMANDS_print_status()
{
	echo "++++   C++ Version Manager   ++++"
	echo "* version            : $CVM_VERSION"
	echo "* stamp              : $(stat -c %y "$OSL_INIT_script_full_path")"
	echo "* using OSL version  : $OSL_VERSION [$OSL_STAMP]"
#	echo "* compset count      : [TODO]"
	echo "* default data dir   : $CVM_DEFAULT_DATA_DIR"
	echo "* current data dir   : $CVM_DATA_DIR"
	echo "* component sets dir : $CVM_COMPSETS_DIR"
	echo "* current compset    : \"`cat \"$CVM_ACTIVE_COMPSET\"`\""
	echo "* current compset components :"
	CVM_COMP_SELECTION_dump

	## tests
	#echo $(CVM_COMPONENT_get_component_target_name lib.boost.1.53)
	#echo $(CVM_COMPONENT_get_component_selected_version lib.boost)
	#echo $(CVM_COMP_INSTALL_substitute_keywords "--with-boost={{dir_result:lib.boost}} --with-pion={{dir_result:lib.pion}}")
}


CVM_COMMANDS_list_compsets()
{
	echo "Currently available C++VM components sets :"
	## note : since we ensure a default compset, there will always be at last one
	for compset_dir in $(find "$CVM_COMPSETS_DIR" -mindepth 1 -maxdepth 1 -type d -print); do
		echo "  $(basename $compset_dir)"
	done
}


CVM_COMMANDS_release_incorrectly_held_locks()
{
	echo "* releasing all incorrectly held rsrc protection locks..."

	## release locks of current compset
	COMPSET_DIR=$(CVM_COMPSET_get_compset_dir $CURRENT_COMPSET)
	oldwd=$(pwd)
	CVM_debug "* moving to \"$COMPSET_DIR\"..."
	cd "$COMPSET_DIR"

	find . -type l -name "*$OSL_MUTEX_SUFFIX" -print -exec rm {} \;

	## now release locks of shared cache
	CVM_debug "* moving to \"$CVM_DATA_DIR\"..."
	cd "$CVM_DATA_DIR"

	find . -type l -name "*$OSL_MUTEX_SUFFIX" -print -exec rm {} \;

	## done
	CVM_debug "* moving back to \"$oldwd\"..."
	cd "$oldwd"
}

CVM_COMMANDS_create_component()
{
	echo "Please enter the component name : (one word, filesystem-friendly, example : foo)"
	read name
	echo "name : $name"
	echo "Please enter the component type : (lib, tool or compiler)"
	read type
	echo "type : $type"
	comp_id="$type.$name"
	comp_dir="$CVM_INTEGRATED_COMP_DEFS_DIR/$comp_id"
	mkdir -p "$comp_dir"
	
	## now copy example files
	stub_file="$comp_dir/$comp_id.stub"
	if ! [[ -f "$stub_file" ]]; then
		cp "$CVM_EXAMPLES_DIR/component/type.name.stub" "$stub_file"
	fi

	apt_file="$comp_dir/$comp_id.apt"
	if ! [[ -f "$apt_file" ]]; then
		cp "$CVM_EXAMPLES_DIR/component/type.name.apt" "$apt_file"
	fi

	version_sample_file="$comp_dir/$comp_id.version_todo"
	if ! [[ -f "$version_sample_file" ]]; then
		cp "$CVM_EXAMPLES_DIR/component/type.name.version" "$version_sample_file"
	fi
}

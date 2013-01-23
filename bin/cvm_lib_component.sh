#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the operations following the requirement of a component
##
## This file is not meant to be executed, only sourced :
##   source cvm_lib_require.sh

## REM : required includes are in main file




CVM_COMPONENT_find_component_dir()
{
	local component_id=$1
	local component_source=$2
	local return_code=1 # error by default
	return_value="XXX C++VM component not found XXX" # error by default
	
	CVM_debug "looking for component : $component_id"
	CVM_debug "     component source : $component_source"

	case $component_source in
	### ...
	"integrated")
		## o rly ?
		CVM_debug "Testing $CVM_INTEGRATED_COMP_DEFS_DIR/$component_id..."
		if [[ -d "$CVM_INTEGRATED_COMP_DEFS_DIR/$component_id" ]]; then
			## OK
			return_value="$CVM_INTEGRATED_COMP_DEFS_DIR/$component_id"
			return_code=0
		else
			## component doesn't exists...
			OSL_OUTPUT_display_error_message "required component \"$component_id\" couldn't be found in integrated components..."
			## return code stays NOK
		fi
		;;
	### ...
	"github")
		OSL_OUTPUT_abort_execution_because_not_implemented
		;;
	### ...
	"git")
		OSL_OUTPUT_abort_execution_because_not_implemented
		;;
	### ...
	"path")
		OSL_OUTPUT_abort_execution_because_not_implemented
		;;
	### ??? command not recognized
	*)
		echo "XXX unrecognized command : $CMD..."
		usage # REM : will exit
		;;
	esac
	
	## one last check ?
	#echo "$return_value"
	if [[ $return_code -ne 0 ]]; then
		## problem
		do_nothing=0
	else
		CVM_debug "found in $return_value"
	fi
	
	return $return_code
}


CVM_COMPONENT_find_known_component_dir()
{
	local component_id=$1
	local return_code=1 # error by default
	return_value="XXX C++VM known component not found XXX" # error by default
	
	CVM_debug "looking for known component : $component_id"

	## first look in cache
	CVM_debug "Testing $CVM_COMP_DEFS_DIR/$component_id..."
	if [[ -d "$CVM_COMP_DEFS_DIR/$component_id" ]]; then
		## OK
		return_value="$CVM_COMP_DEFS_DIR/$component_id"
		return_code=0
	## if not cached, must be an integrated component
	elif [[ -d "$CVM_INTEGRATED_COMP_DEFS_DIR/$component_id" ]]; then
		## OK
		return_value="$CVM_INTEGRATED_COMP_DEFS_DIR/$component_id"
		return_code=0
	else
		## component doesn't exists...
		OSL_OUTPUT_display_error_message "required known component \"$component_id\" couldn't be found... This should not happen ! (internal error)"
		## return code stays NOK
	fi
	
	## one last check ?
	#echo "$return_value"
	if [[ $return_code -ne 0 ]]; then
		## problem
		do_nothing=0
	else
		CVM_debug "found in $return_value"
	fi
	
	return $return_code
}


CVM_COMPONENT_get_component_type()
{
	local component_id=$1
	local return_code=1 # error by default
	return_value="error" # error by default
	
	CVM_debug "parsing component type of : $component_id"
	IFS="."
	typeset -a component_id_dot_splitted=( $component_id )
	local comp_type=${component_id_dot_splitted[0]}
	case $component_id in
	"compiler.*")
		## OK
		return_value="compiler"
		return_code=0
		;;
	"tool.*")
		## OK
		return_value="tool"
		return_code=0
		;;
	"lib.*")
		## OK
		return_value="lib"
		return_code=0
		;;
	*)
		## ??? unknown type
		OSL_OUTPUT_display_error_message "unknown component type for : $component_id"
		## ret code stays false
		;;
	esac

	return $return_code
}


CVM_COMPONENT_get_component_target_name()
{
	local component_id=$1
	local return_code=1 # error by default

	#CVM_debug "parsing component target name for : $component_id"

	echo "${component_id#*.}"
	return_code=0
	
	return $return_code
}


CVM_COMPONENT_get_component_shared_archive_path()
{
	local component_version=$1
	local return_code=1 # error by default

	local raw_archive=`ls -A -1 --color=never $CVM_ARCHIVES_DIR/$component_version/*`
	local archive=$(basename "$raw_archive")
	
	echo "$CVM_ARCHIVES_DIR/$component_version/$archive"
	return_code=0

	return $return_code
}


CVM_COMPONENT_get_component_shared_src_dir()
{
	local component_version=$1

	echo "$CVM_SRC_DIR/$component_version"

	return 0
}


CVM_COMPONENT_get_component_build_dir()
{
	local component_version=$1

	## REM : we are supposed to be in the current compset dir
	echo "$CVM_COMP_INSTALL_BUILD_DIR_NAME/$component_version"

	return 0
}


CVM_COMPONENT_get_component_prefix()
{
	local component_version=$1

	## REM : we are supposed to be in the current compset dir
	echo "$CVM_COMP_INSTALL_FINAL_DIR_NAME/$component_version"

	return 0
}


CVM_COMPONENT_get_component_include_dir()
{
	local component_version=$1

	## REM : we are supposed to be in the current compset dir
	echo "$(CVM_COMPONENT_get_component_prefix "$component_version")/include"

	return 0
}


CVM_COMPONENT_get_component_lib_dir()
{
	local component_version=$1

	## REM : we are supposed to be in the current compset dir
	echo "$(CVM_COMPONENT_get_component_prefix "$component_version")/lib"

	return 0
}


CVM_COMPONENT_get_component_bin_dir()
{
	local component_version=$1

	## REM : we are supposed to be in the current compset dir
	echo "$(CVM_COMPONENT_get_component_prefix "$component_version")/bin"

	return 0
}


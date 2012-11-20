#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_compset.sh

## REM : required includes are in main file


## constants
CVM_COMPSET_DEFAULT_COMPSET_NAME="default"


CVM_COMPSET_get_compset_dir()
{
	local compset_name=$1
	local COMPSET_DIR="$CVM_COMPSETS_DIR/$compset_name"
	echo "$COMPSET_DIR"
}

CVM_COMPSET_get_compset_compfile()
{
	local compset_name=$1
	local COMPSET_DIR=$(CVM_COMPSET_get_compset_dir $compset_name)
	local COMPSET_FILE="$COMPSET_DIR/$CVM_DEFAULT_COMPFILE_NAME"
	echo "$COMPSET_FILE"
}


CVM_COMPSET_check_compset()
{
	local compset_name=$1
	
	CVM_debug "checking compset \"$compset_name\"..."
	
	## check if such a compset already exists
	OSL_RSRC_check "$CVM_COMPSETS_DIR" $compset_name
	local compset_exists_and_is_ok=$?
	
	## ... do more checks ?
	
	return $compset_exists_and_is_ok
}


## try to create the compset
## and *complains* if it already exists
## (useful for user-created compsets)
CVM_COMPSET_create_compset_if_needed()
{
	local compset_name=$1
	
	CVM_debug "creating compset \"$compset_name\" if needed..."
	
	## check if such a compset already exists
	CVM_COMPSET_check_compset $compset_name
	local compset_exists_and_is_ok=$?
	if [[ $compset_exists_and_is_ok -eq 0 ]]; then
		## compset already exists !
		echo "Component set \"$compset_name\" already exists. Nothing done."
	else
		## create it
		CVM_COMPSET_create_compset $compset_name
	fi
}


## try to create the compset
## but *does nothing* if it already exists
## (useful for automatically created compsets)
CVM_COMPSET_ensure_compset()
{
	local compset_name=$1

	CVM_debug "Ensuring compset \"$compset_name\"..."
	
	## check if such a compset already exists
	CVM_COMPSET_check_compset $compset_name
	local compset_exists_and_is_ok=$?
	if [[ $compset_exists_and_is_ok -eq 0 ]]; then
		## compset already exists
		do_nothing=1
	else
		## create it
		CVM_COMPSET_create_compset $compset_name
	fi
}


CVM_COMPSET_create_compset()
{
	local compset_name=$1
	local return_code=1 ## !0 = failure, by default

	CVM_debug "creating compset \"$compset_name\"..."
	
	## take rsrc lock
	local rsrc_id=$compset_name
	local rsrc_dir=$CVM_COMPSETS_DIR
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"

	## a dir for the component set
	local COMPSET_DIR=$(CVM_COMPSET_get_compset_dir $compset_name)
	mkdir -p "$COMPSET_DIR"

	## a description file
	local COMPSET_FILE=$(CVM_COMPSET_get_compset_compfile $compset_name)
	## create the file from a model if possible
	touch "$COMPSET_FILE"
	if [[ -f "$OSL_INIT_script_full_dir/../compfile.example" ]]; then
		## example file is available
		cp "$OSL_INIT_script_full_dir/../compfile.example" "$COMPSET_FILE"
	else
		## build a minimal compset file
		echo "## C++ VM component set definition" >> "$COMPSET_FILE"
	fi
	return_code=$?
	
	## release lock
	OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "Concurrent access to compset \"$compset_name\" !"
		return_code=1 # error
	fi

	## remember this compset as active
	CVM_COMPSET_save_current_active_compset $compset_name

	if [[ $return_code -ne 0 ]]; then
		## failure...
		echo "XXX Component set \"$compset_name\" could not be created..."
	else
		echo "Component set \"$compset_name\" created successfully."
	fi
	
	return $return_code
}


CVM_COMPSET_save_current_active_compset()
{
	local compset_name=$1
	
	CVM_debug "Remembering active compset \"$compset_name\"..."
	
	## check if such a compset already exists
	CVM_COMPSET_check_compset $compset_name
	local compset_exists_and_is_ok=$?
	if [[ $compset_exists_and_is_ok -eq 0 ]]; then
		## compset exists and is fine
		echo "$compset_name" > "$CVM_ACTIVE_COMPSET"
	else
		## doesn't exist !
		echo "XXX component set \"$compset_name\" doesn't exist !"
	fi
}


CVM_COMPSET_get_current_active_compset()
{
	cat "$CVM_ACTIVE_COMPSET"
}


CVM_COMPSET_delete_compset()
{
	local compset_name=$1
	
	CVM_debug "creating compset \"$compset_name\"..."
	OSL_OUTPUT_abort_execution_because_not_implemented
}


CVM_COMPSET_ensure_default_compset()
{
	local compset_name=$CVM_COMPSET_DEFAULT_COMPSET_NAME
	CVM_COMPSET_ensure_compset $compset_name
	local compset_exists_and_is_ok=$?
	if [[ $compset_exists_and_is_ok -eq 0 ]]; then
		## compset exists and is fine
		if [[ -f "$CVM_ACTIVE_COMPSET" ]]; then
			do_nothing=1
		else
			CVM_COMPSET_save_current_active_compset $compset_name
		fi
	else
		## doesn't exist !
		echo "XXX Default component set \"$compset_name\" counldn't be created !"
	fi
}


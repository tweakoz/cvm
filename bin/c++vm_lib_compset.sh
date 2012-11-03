#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_compset.sh

source osl_lib_rsrc.sh

source c++vm_lib_base.sh


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


CVM_COMPSET_create_compset()
{
	local compset_name=$1
	local return_code=1 ## !0 = failure, by default

	CVM_debug "creating compset \"$compset_name\"..."
	
	## take rsrc lock
	OSL_RSRC_begin_managed_write_operation "$CVM_COMPSETS_DIR" $compset_name
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		## failure ? Should not happen...
		echo "couldn't get write lock..."
	else
		## a dir for the component set
		COMPSET_DIR="$CVM_COMPSETS_DIR/$compset_name"
		mkdir -p "$COMPSET_DIR"
		
		## a description file
		COMPSET_FILE="$COMPSET_DIR/compfile"
		## create the file from a model if possible
		touch "$COMPSET_FILE"
		if [[ -f "$OSL_INIT_script_full_dir/../compfile.example" ]]; then
			## example file is available
			cp "$OSL_INIT_script_full_dir/../compfile.example" "$COMPSET_FILE"
		else
			## build a minimal compset file
			echo "## C++ VM component set definition" >> "$COMPSET_FILE"
		fi
		
		## release lock
		OSL_RSRC_end_managed_write_operation "$CVM_COMPSETS_DIR" $compset_name
		return_code=$?
		
		## remember this compset as active
		CVM_COMPSET_save_current_active_compset $compset_name
	fi

	if [[ $return_code -ne 0 ]]; then
		## failure...
		echo "XXX Component set \"$compset_name\" could not be created..."
	else
		echo "Component set \"$compset_name\" created successfully."
	fi
	
	return $return_code
}


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


CVM_COMPSET_delete_compset()
{
	local compset_name=$1
	
	CVM_debug "creating compset \"$compset_name\"..."
	OSL_OUTPUT_abort_execution_because_not_implemented
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


CVM_COMPSET_ensure_default_compset()
{
	local compset_name="default"
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




CVM_COMPSET_update_compset()
{
	local compset_name=$1
	
	CVM_debug "Updating compset \"$compset_name\"..."
	
	## check if such a compset already exists
	CVM_COMPSET_check_compset $compset_name
	local compset_exists_and_is_ok=$?
	if [[ $compset_exists_and_is_ok -eq 0 ]]; then
		## compset exists and is fine
		OSL_OUTPUT_abort_execution_because_not_implemented
	else
		## doesn't exist !
		echo "XXX component set \"$compset_name\" doesn't exist !"
	fi
}


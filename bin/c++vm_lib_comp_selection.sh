#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the operations on component selection files
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_comp_selection.sh

## REM : required includes are in main file


CVM_COMP_SELECTION_get_compfile_for()
{
	local component_id=$1
	local corresponding_compfile=$CVM_COMP_SELECTION_DIR_NAME/$component_id
	echo "$corresponding_compfile"
}


## prerequisite : we are supposed to be in selected compset dir
## return code : 0 if was already present,
##               1 if not
CVM_COMP_SELECTION_add_if_needed()
{
	local component_id=$1
	local return_code=1 # error/not exist by default
	
	CVM_debug "adding component selection for : $component_id"

	local COMP_SEL_FILE=$(CVM_COMP_SELECTION_get_compfile_for $component_id)
	if [[ -f "$COMP_SEL_FILE" ]]; then
		## already exists
		CVM_debug "(already exists)"
		return_code=0
	else
		CVM_debug "(created)"
		touch $COMP_SEL_FILE
	fi
	
	## that's all
	
	return $return_code
}


CVM_COMP_SELECTION_add_component_info_if_needed()
{
	local component_id=$1
	local info_line=$2
	local return_code=1 # error by default
	
	CVM_debug "adding info line to component selection of \"$component_id\"..."
	
	## first find the depending component file
	local COMP_SEL_FILE=$(CVM_COMP_SELECTION_get_compfile_for $component_id)

	## now loop
	local found=false
	local output=`cat "$COMP_SEL_FILE" | grep "$info_line"`
	# to split lines along \n, we must change the IFS
	IFS='
' # this makes IFS a newline
	for line in $output; do
		CVM_debug $line
		if [[ "$line" == "$info_line" ]]; then
			## already here
			found=true
			break
		fi
	done
	OSL_INIT_restore_default_IFS
	
	if [[ $found == true ]]; then
		CVM_debug "-> info already here."
	else
		CVM_debug "-> info was new, added."
		echo "$info_line" >> "$COMP_SEL_FILE"
	fi
	return_code=0 ## OK
	
	return $return_code
}
	
CVM_COMP_SELECTION_add_component_dependency_if_needed()
{
	local component_id=$1
	local depended_on_component_id=$2
	local return_code=1 # error by default
	
	CVM_debug "adding dependency to \"$depended_on_component_id\" to component selection  of \"$component_id\" ..."

	## prepare req line
	local line="require $depended_on_component_id"
	
	## and add it if needed
	CVM_COMP_SELECTION_add_component_info_if_needed  $component_id  "$line"
	return_code=$?
	
	return $return_code
}


CVM_COMP_SELECTION_add_component_stub_info_if_needed()
{
	local component_id=$1
	local return_code=1 # error by default
	
	CVM_debug "adding stub info to component selection of \"$component_id\"..."
	
	## prepare line
	local line="stub"

	## and add it if needed
	CVM_COMP_SELECTION_add_component_info_if_needed  $component_id  "$line"
	return_code=$?
	
	return $return_code
}


CVM_COMP_SELECTION_add_minimum_required_version_to_comp_sel()
{
	local component_id=$1
	local return_code=1 # error by default
	
	OSL_OUTPUT_warn_not_implemented CVM_COMP_SELECTION_add_minimum_required_version_to_comp_sel
	
	return $return_code
}


CVM_COMP_SELECTION_add_maximum_required_version_to_comp_sel()
{
	local component_id=$1
	local return_code=1 # error by default
	
	OSL_OUTPUT_warn_not_implemented CVM_COMP_SELECTION_add_maximum_required_version_to_comp_sel
	
	return $return_code
}


CVM_COMP_SELECTION_add_explicit_required_version_to_comp_sel()
{
	local component_id=$1
	local return_code=1 # error by default
	
	OSL_OUTPUT_warn_not_implemented CVM_COMP_SELECTION_add_maximum_required_version_to_comp_sel
	
	return $return_code
}

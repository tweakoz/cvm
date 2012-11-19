#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the operations following the requirement of a component
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_require.sh

## REM : required includes are in main file


CVM_COMPONENT_process_component()
{
	local component_id=$1
	local required_version=$2
	local component_source=$3
	local return_code=1 # error by default
	
	CVM_debug "requiring component : $component_id"
	CVM_debug "   required version : $required_version"
	CVM_debug "   component source : $component_source"

	CVM_COMPONENT_find_component $component_id $component_source
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		## comp couldn't be found...
		do_nothing=1
	else
		local component_path=$return_value
		## component found
		
		OSL_OUTPUT_abort_execution_because_not_implemented
	fi
	
	return $return_code
}

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



CVM_COMPONENT_find_best_matching_component()
{
	local component_id=$1
	local return_code=1 # error by default
	
	CVM_debug "looking for best matching component for : $component_id"

	## for now, just forward to previous
	CVM_COMPONENT_find_component_dir $component_id "integrated"
	return_code=$?
	
	if [[ $return_code -ne 0 ]]; then
		## problem
		return_value="XXX C++VM best matching component not found XXX" # error by default
	else
		return_code=1 # again, error by default
		local comp_def_dir="$return_value"
		local oldwd=$(pwd)
		CVM_debug "* moving to \"$comp_def_dir\"..."
		cd "$comp_def_dir"
		
		## now select the best version
		## first read current requirements
		local min_version_authorized=""
		local max_version_authorized=""
		local exact_version_required=""
		## TODO : actually read those data !
		## Now list all available versions
		## note : we ask for a reverse sort, so newer versions are coming first
		output=`ls --almost-all -1 --reverse --color=none $component_id.*`
		## now parse the results
		## to split lines along \n, we must change the IFS
		IFS='
' ## this makes IFS a newline
		local found=false
		local selected_version=""
		## now loop over all available versions
		for line in $output; do
			local possible_version=${line#$component_id.}
			CVM_debug "testing version \"$possible_version\"..."
			if [[ -n $exact_version_required ]]; then
				if [[ $possible_version == $exact_version_required ]]; then
					## ok, found !
					CVM_debug "exact required version found !"
					selected_version=$line
					found=true
					break
				fi
			## hat tip http://stackoverflow.com/a/806923/587407
			elif ! [[ "$possible_version" =~ ^[0-9]+([.][0-9]+)?$ ]] ; then
				## hack to test if version = system and no version requirements all in one test
				if [[ "system$min_version_authorized$max_version_authorized" == "$possible_version" ]]; then
					## ok, system will do since there are no version requirements
					CVM_debug "system version found and accepted !"
					selected_version=$line
					found=true
					break
				else
					echo "error: Not a version number : $possible_version"
				fi
			else
				local min_ok=1 ## ok
				if [[ -n "$min_version_authorized" ]]; then
					$(OSL_VERSION_test_greater_or_equal $possible_version $min_version_authorized)
					min_ok=$?
				fi
				local max_ok=1 ## ok
				if [[ -n "$max_version_authorized" ]]; then
					$(OSL_VERSION_test_smaller_or_equal $possible_version $max_version_authorized)
					max_ok=$?
				fi
				
				if ! [[ $min_ok -eq 1 ]]; then
					CVM_debug " X doesn't match min version requirement"
				elif ! [[ $max_ok -eq 1 ]]; then
					CVM_debug " X doesn't match max version requirement"
				else
					## ok, found !
					CVM_debug "acceptable version found !"
					selected_version=$line
					found=true
					break
				fi
			fi ## exact version specified ?
		done
		
		CVM_debug "* moving back to \"$oldwd\"..."
		cd "$oldwd"

		if [[ $found == "false" ]]; then
			return_value="XXX C++VM best matching component not found XXX"
			OSL_OUTPUT_display_error_message "Couldn't find an acceptable version for component : $component_id..."
			## return code stays false
		else
			return_value=$return_value/$selected_version
			
			## prepare line
			local line="selected_version $selected_version"
			
			## and add it if needed
			CVM_COMP_SELECTION_add_component_info_if_needed  $component_id  "$line"
			return_code=$?
		fi
	fi
	
	return $return_code
}

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


CVM_COMP_SELECTION_test_if_already_selected()
{
	local component_id=$1
	local return_code=1 # error / not already selected by default
	
	CVM_debug "Checking if component \"$component_id\" has already been selected..."

	local COMP_SEL_FILE=$(CVM_COMP_SELECTION_get_compfile_for $component_id)
	if [[ -f "$COMP_SEL_FILE" ]]; then
		## check if the "selected version" is set
		local output=`cat "$COMP_SEL_FILE" | grep "selected_version "`
		[[ -n "$output" ]] && return_code=0
	fi

	if [[ $return_code -ne 0 ]]; then
		CVM_debug "  --> not selected yet"
	else
		CVM_debug "  --> already selected"
	fi
	
	return $return_code
}


CVM_COMP_SELECTION_select_component()
{
	local component_id=$1
	local component_source=$2
	local min_version_authorized=$3
	local max_version_authorized=$4
	local exact_version_required=$5
	local return_code=1 # error by default
	
	CVM_debug "selecting component \"$component_id\" from \"$component_source\" with version >= $min_version_authorized < $max_version_authorized =$exact_version_required..."
	
	CVM_COMP_SELECTION_find_best_matching_component "$component_id" "" "$min_version_authorized" "$max_version_authorized" "$exact_version_required"
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		## comp couldn't be found...
		## an error was already displayed
		do_nothing=1
	else
		local component_path=$return_value
		CVM_debug "found component $component_id at $component_path"
		## component found
		CVM_COMPFILE_parse_compfile $return_value $component_id "CVM_COMPFILE_parse_compfile_line"
		return_code=$?
	fi
	
	return $return_code
}


CVM_COMP_SELECTION_find_best_matching_component()
{
	local component_id=$1
	## $2
	local min_version_authorized=$3
	local max_version_authorized=$4
	local exact_version_required=$5
	local return_code=1 # error by default

	## note : "system" and "stub" are synonymous
	if [[ $exact_version_required == "system" ]]; then
		exact_version_required="stub"
	fi
	
	CVM_debug "looking for best matching component for \"$component_id\" with version reqs >= $min_version_authorized < $max_version_authorized =$exact_version_required..."

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
			elif ! [[ "$possible_version" =~ ^[0-9]+([.][0-9])?([.][0-9]+)?([.][0-9]+)?$ ]] ; then
				local no_version_specified=false
				if [[ -z "$min_version_authorized$max_version_authorized" ]]; then
					no_version_specified=true
				fi
				case $possible_version in
				"apt")
					if [[ "$no_version_specified" == "true" ]]; then
						if [[ $(OSL_CAPABILITIES_has_apt) == "true" ]]; then
							## ok, default apt version is fine since there are no version requirements
							CVM_debug "apt version found and accepted !"
							selected_version=$line
							found=true
							break
						fi
					fi
					;;
				"stub")
					## ignored. Stub is never automatically selected.
					;;
				### any other non standard version
				*)
					OSL_OUTPUT_display_error_message "Unknown version number : $possible_version"
					## return_code stays NOK
					;;
				esac
			else
				local min_nok=0 ## ok
				if [[ -n "$min_version_authorized" ]]; then
					$(OSL_VERSION_test_greater_or_equal $possible_version $min_version_authorized)
					min_nok=$?
				fi
				local max_nok=0 ## ok
				if [[ -n "$max_version_authorized" ]]; then
					$(OSL_VERSION_test_strictly_smaller $possible_version $max_version_authorized)
					max_nok=$?
				fi
				
				if [[ $min_nok -ne 0 ]]; then
					CVM_debug " -> $possible_version doesn't match min version requirement ($min_version_authorized)"
				elif [[ $max_nok -ne 0 ]]; then
					CVM_debug " -> $possible_version doesn't match max version requirement ($max_version_authorized)"
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


## prerequisite : we are supposed to be in selected compset dir
## return code : 0 if was already present,
##               1 if not
CVM_COMP_SELECTION_add_if_needed()
{
	local component_id=$1
	local return_code=1 # error/not exist by default
	
	CVM_debug "adding component selection for : $component_id..."

	local COMP_SEL_FILE=$(CVM_COMP_SELECTION_get_compfile_for $component_id)
	if [[ -f "$COMP_SEL_FILE" ]]; then
		## already exists
		CVM_debug "  --> already exists"
		return_code=0
	else
		CVM_debug "  --> created : $(CVM_COMPSET_get_current_compset_dir)/$COMP_SEL_FILE"
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
	
	CVM_debug "adding info line to component selection of \"$component_id\" : "
	
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
	
	CVM_debug "adding dependency to \"$depended_on_component_id\" to component selection of \"$component_id\" ..."

	## prepare req line
	local line="require $depended_on_component_id"
	
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

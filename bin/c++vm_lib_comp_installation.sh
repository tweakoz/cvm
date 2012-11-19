#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the operations on component selection files
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_comp_installation.sh

## REM : required includes are in main file


## sorry, I use state variables
CVM_COMP_INSTALL_last_seen_selected_version=""
CVM_COMP_INSTALL_selected_compiler=""
CVM_COMP_INSTALL_current_component_data=""


CVM_COMP_INSTALL_upgrade_compset()
{
	local compset_name=$1
	local return_code=1 # Error by default
	
	CVM_debug "* upgrading compset : \"$compset_name\"..."

	local COMPSET_DIR=$(CVM_COMPSET_get_compset_dir $compset_name)
	local oldwd=$(pwd)
	CVM_debug "* moving to \"$COMPSET_DIR\"..."
	cd "$COMPSET_DIR"
	
	## We will now rebuild the component selection
	## This is a complex shared rsrc
	OSL_RSRC_begin_managed_write_operation . $CVM_COMP_INSTALL_FINAL_DIR_NAME
	rm -rf $CVM_COMP_INSTALL_FINAL_DIR_NAME
	mkdir $CVM_COMP_INSTALL_FINAL_DIR_NAME
	mkdir $CVM_COMP_INSTALL_FINAL_DIR_NAME/build
	mkdir $CVM_COMP_INSTALL_FINAL_DIR_NAME/bin
	mkdir $CVM_COMP_INSTALL_FINAL_DIR_NAME/lib
	
	## start with root component
	CVM_COMP_INSTALL_parse_compselfile_for_component $CVM_ROOT_COMPONENT_NAME
	return_code=$?
	
	if [[ $return_code -ne 0 ]]; then
		## error during file parsing
		## An error message should already have been displayed.
		OSL_OUTPUT_display_error_message "Upgrade failed..."
		OSL_RSRC_end_managed_write_operation_with_error . $CVM_COMP_INSTALL_FINAL_DIR_NAME
	else
		## everything went OK
		OSL_RSRC_end_managed_write_operation . $CVM_COMP_INSTALL_FINAL_DIR_NAME
	fi
	
	CVM_debug "* moving back to \"$oldwd\"..."
	cd "$oldwd"
	
	return $return_code
}


CVM_COMP_INSTALL_parse_compselfile_for_component()
{
	local component_id=$1
	local return_code=1 # Error by default

	local COMPSEL_FILE=$(CVM_COMP_SELECTION_get_compfile_for $component_id)
	CVM_debug "* parsing component selection file : \"$COMPSEL_FILE\"..."

	## and start parsing, for default component
	CVM_COMPFILE_parse_compfile "$COMPSEL_FILE" $component_id "CVM_COMP_INSTALL_parse_compselfile_line"
	return_code=$?
	
	return $return_code
}

CVM_COMP_INSTALL_parse_compselfile_line()
{
	local line="$*"
	local return_code=0 # OK until found otherwise
	CVM_debug "parsing component selection file line \"$line\"..."
	
	IFS=" "
	## REM : -a = array, splitted along IFS
	typeset -a line_space_splitted=( $line )
	#CVM_debug "- : ${line_space_splitted}"
	#CVM_debug "0 : ${line_space_splitted[0]}"
	#CVM_debug "1 : ${line_space_splitted[1]}"
	#CVM_debug "2 : ${line_space_splitted[2]}"
	
	local line_cmd=${line_space_splitted[0]}
	local cmd_length=${#line_cmd}
	local line_data=${line:$cmd_length}
	#CVM_debug "line cmd  = : \"$line_cmd\"..."
	#CVM_debug "line data = : \"$line_data\"..."
	
	case $line_cmd in
	### ...
	"include")
		##CVM_COMPFILE_process_line_include "$line_data"
		##return_code=$?
		OSL_OUTPUT_warn_not_implemented "include"
		return_code=1
		;;
	### ...
	"require")
		CVM_COMP_INSTALL_process_line_require "$line_data"
		return_code=$?
		;;
	### ...
	"selected_version")
		CVM_COMP_INSTALL_process_line_selected_version "$line_data"
		return_code=$?
		;;
	### ...
	"stub")
		##CVM_COMPFILE_process_line_stub "$line_data"
		##return_code=$?
		OSL_OUTPUT_warn_not_implemented "stub"
		return_code=1
		## means that this file contains no more useful information
		break ## we can stop here
		;;
	### ??? command not recognized
	*)
		OSL_OUTPUT_warn "unrecognized component selection file command : \"$line_cmd\"..."
		#return_code=1 ## error
		;;
	esac

	OSL_INIT_restore_default_IFS
	
	return $return_code
}


CVM_COMP_INSTALL_process_line_selected_version()
{
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing comp selection file cmd selected_version..."
	
	IFS=","
	typeset -a line_data_comma_splitted=( $line_data )
	#CVM_debug "# : ${#line_data_comma_splitted[@]}"
	#CVM_debug "@ : ${line_data_comma_splitted[@]}"
	#CVM_debug "0 : ${line_data_comma_splitted[0]}"
	#CVM_debug "1 : ${line_data_comma_splitted[1]}"
	#CVM_debug "2 : ${line_data_comma_splitted[2]}"

	## just check that there is at last one param
	if [[ ${#line_data_comma_splitted[@]} -lt 1 ]]; then
		OSL_OUTPUT_display_error_message "syntax error : selected_version cmd takes at last one parameter"
		## return code stays NOK
	else
		## now decode parameters
		CVM_COMP_INSTALL_last_seen_selected_version=$(OSL_STRING_trim ${line_data_comma_splitted[0]})
		return_code=0
	fi ## param OK ?
	
	CVM_debug "selected_version line processing done : $return_code, $CVM_COMP_INSTALL_last_seen_selected_version"
	
	return $return_code
}


CVM_COMP_INSTALL_process_line_require()
{
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing comp selection file cmd require..."

	## to allow recursion since we have a state
	local old_last_seen_selected_version=$CVM_COMP_INSTALL_last_seen_selected_version
	
	IFS=","
	typeset -a line_data_comma_splitted=( $line_data )
	#CVM_debug "# : ${#line_data_comma_splitted[@]}"
	#CVM_debug "@ : ${line_data_comma_splitted[@]}"
	#CVM_debug "0 : ${line_data_comma_splitted[0]}"
	#CVM_debug "1 : ${line_data_comma_splitted[1]}"
	#CVM_debug "2 : ${line_data_comma_splitted[2]}"

	## just check that there is at last one param
	if [[ ${#line_data_comma_splitted[@]} -lt 1 ]]; then
		OSL_OUTPUT_display_error_message "syntax error : require cmd takes at last one parameter"
		## return code stays NOK
	else
		## now decode parameters
		local component_id=$(OSL_STRING_trim ${line_data_comma_splitted[0]})
		
		## check if this component is already installed properly
		OSL_RSRC_check $CVM_COMP_INSTALL_FINAL_DIR_NAME/build $component_id
		return_code=$? ## REM 0 = OK
		if [[ $return_code -eq 0 ]]; then
			## OK, already installed
			CVM_debug "Component \"$component_id\" is already installed properly."
			do_nothing=1
		else
			## parse this component own selection file
			## in order to install its dependencies first
			CVM_COMP_INSTALL_parse_compselfile_for_component $component_id
			return_code=$?
		
			if [[ $return_code -ne 0 ]]; then
				OSL_OUTPUT_display_error_message "dependencies failed for component \"$component_id\"..."
				## return code stays NOK
			else
				## then install the component itself
				CVM_COMP_INSTALL_ensure_component_installed $component_id
				return_code=$?
			fi ## dependencies OK ?
		fi ## already installed OK ?
	fi ## param OK ?
	
	CVM_debug "require line processing done : $return_code"
	CVM_COMP_INSTALL_last_seen_selected_version=$old_last_seen_selected_version
	
	return $return_code
}


CVM_COMP_INSTALL_ensure_component_installed()
{
	local component_id=$1
	local return_code=1 # error/not exist by default
	
	CVM_debug "installing component : $component_id / $CVM_COMP_INSTALL_last_seen_selected_version"

	OSL_RSRC_begin_managed_write_operation $CVM_COMP_INSTALL_FINAL_DIR_NAME/build $component_id
	
	CVM_COMP_INSTALL_load_component_data  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
	return_code=$?
	
	CVM_COMP_INSTALL_install_loaded_component  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
	return_code=$?
	
	if [[ $return_code -ne 0 ]]; then
		## error during file parsing
		## An error message should already have been displayed.
		OSL_OUTPUT_display_error_message "Install failed..."
		OSL_RSRC_end_managed_write_operation_with_error $CVM_COMP_INSTALL_FINAL_DIR_NAME/build $component_id
	else
		## everything went OK
		OSL_OUTPUT_display_success_message "Install of $component_id done"
		OSL_RSRC_end_managed_write_operation $CVM_COMP_INSTALL_FINAL_DIR_NAME/build $component_id
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_load_component_data()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "loading component data for $component_id..."

	CVM_COMPONENT_find_known_component_dir $component_id
	return_code=$?
	
	if [[ $return_code -ne 0 ]]; then
		## an error message was already displayed
		do_nothing=1
	else
		local expected_compfile="$return_value/$component_version" 
		if ! [[ -f "$expected_compfile" ]]; then
			OSL_OUTPUT_display_error_message "required known component version \"$component_version\" couldn't be found... This should not happen ! (internal error)"
			return_code=1 # error
		else
			return_code=1 # error/not exist by default
			
			## and start parsing, for default component
			CVM_COMP_INSTALL_current_component_data=""
			CVM_COMPFILE_parse_compfile "$expected_compfile" $component_id "CVM_COMP_INSTALL_parse_line_load_compfile_data"
			return_code=$?
		fi
	fi
	
	return $return_code
}



CVM_COMP_INSTALL_parse_line_load_compfile_data()
{
	local line="$*"
	local return_code=0 # OK until found otherwise
	CVM_debug "loading component version data line \"$line\"..."
	
	IFS=" "
	## REM : -a = array, splitted along IFS
	typeset -a line_space_splitted=( $line )
	#CVM_debug "- : ${line_space_splitted}"
	#CVM_debug "0 : ${line_space_splitted[0]}"
	#CVM_debug "1 : ${line_space_splitted[1]}"
	#CVM_debug "2 : ${line_space_splitted[2]}"
	
	local line_cmd=${line_space_splitted[0]}
	local cmd_length=${#line_cmd}
	local line_data=${line:$cmd_length}
	#CVM_debug "line cmd  = : \"$line_cmd\"..."
	#CVM_debug "line data = : \"$line_data\"..."
	
	case $line_cmd in
	### ...
	"include")
		##CVM_COMPFILE_process_line_include "$line_data"
		##return_code=$?
		OSL_OUTPUT_warn_not_implemented "include"
		return_code=1
		;;
	### ...
	"require")
		## ignored
		do_nothing=1
		;;
	### ...
	"selected_version")
		## ignored
		do_nothing=1
		;;
	### any other command
	*)
		CVM_COMP_INSTALL_current_component_data="$CVM_COMP_INSTALL_current_component_data
		$line"
		return_code=0
		;;
	esac

	OSL_INIT_restore_default_IFS
	
	return $return_code
}


CVM_COMP_INSTALL_install_loaded_component()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	echo "installing component \"$component_id\" with version \"$component_version\"..."

	## TODO
	CVM_debug_multi $CVM_COMP_INSTALL_current_component_data
	
	## first check install mode
	CVM_COMP_INSTALL_get_value_from_cached_component_for "install_mode"
	## let's pretend it worked
	return_code=0

	
	return $return_code
}

CVM_COMP_INSTALL_get_value_from_cached_component_for()
{
	
}

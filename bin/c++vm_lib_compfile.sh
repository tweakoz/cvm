#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the parsing of compfiles
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_compfile.sh

## REM : required includes are in main file




## sorry, I use state variables
CVM_COMPFILE_current_parsed_file=""
CVM_COMPFILE_current_component=""


CVM_COMPFILE_set()
{
	local compfile_path=$1
	local compset_name=$2
	
	local COMPSET_DIR=$(CVM_COMPSET_get_compset_dir $compset_name)
	local COMPSET_FILE=$(CVM_COMPSET_get_compset_compfile $compset_name)
	
	cp "$compfile_path" "$COMPSET_FILE"
}


CVM_COMPFILE_update_compset()
{
	local compset_name=$1
	local return_code=1 # Error by default
	
	local COMPSET_DIR=$(CVM_COMPSET_get_compset_dir $compset_name)
	local oldwd=$(pwd)
	CVM_debug "* moving to \"$COMPSET_DIR\"..."
	cd "$COMPSET_DIR"
	local COMPSET_FILE=$(CVM_COMPSET_get_compset_compfile $compset_name)
	CVM_debug "* applying compfile \"$COMPSET_FILE\"..."
	
	## We will now rebuild the component selection
	## This is a complex shared rsrc
	OSL_RSRC_begin_managed_write_operation . $CVM_COMP_SELECTION_DIR_NAME
	rm -rf $CVM_COMP_SELECTION_DIR_NAME
	mkdir $CVM_COMP_SELECTION_DIR_NAME
	
	## add root component
	CVM_COMPFILE_current_component=$CVM_ROOT_COMPONENT_NAME
	CVM_COMP_SELECTION_add_if_needed $CVM_COMPFILE_current_component
	
	## and start parsing, for default component
	CVM_COMPFILE_parse_compfile "$COMPSET_FILE" $CVM_COMPFILE_current_component "CVM_COMPFILE_parse_compfile_line"
	return_code=$?
	
	if [[ $return_code -ne 0 ]]; then
		## error during file parsing
		## An error message should already have been displayed.
		OSL_OUTPUT_display_error_message "Update failed..."
		OSL_RSRC_end_managed_write_operation_with_error . $CVM_COMP_SELECTION_DIR_NAME
	else
		## everything went OK
		OSL_RSRC_end_managed_write_operation . $CVM_COMP_SELECTION_DIR_NAME
	fi
	
	CVM_debug "* moving back to \"$oldwd\"..."
	cd "$oldwd"
	
	return $return_code
}

CVM_COMPFILE_parse_compfile()
{
	local compfile_path=$1
	local component_id=$2
	local line_parsing_callback=$3
	local return_code=0 # OK until found otherwise

	CVM_debug ">>> parsing file \"$compfile_path\"..."

	if [[ -f "$compfile_path" ]]; then
		## file exists, OK
		do_nothing=1
	else
		## uh oh...
		OSL_OUTPUT_display_error_message "file \"$compfile_path\" not found !"
		return 1
	fi
	
	## prepare for recursivity
	local previous_parsed_file=$CVM_COMPFILE_current_parsed_file
	local previous_parsed_component=$CVM_COMPFILE_current_component
	CVM_COMPFILE_current_parsed_file=$compfile_path
	CVM_COMPFILE_current_component=$component_id

	local line_count=0
	while read line ## REM : source file given at the end
	do
		line_count=$(expr $line_count + 1)
		#CVM_debug ">>> $line"
		if [[ ${#line} == 0 ]]; then
			#CVM_debug "    -> blank line"
			do_nothing=1
		elif [[ ${line:0:1} == "#" ]]; then
			## if line begins with a #, it's a comment and should be ignored
			#CVM_debug "    -> comment"
			do_nothing=1
		else
			## line contains relevant data and should be further parsed
			#CVM_debug "    -> real line"
			## hat tip to http://stackoverflow.com/a/5681040/587407
			$line_parsing_callback "$line"
			return_code=$?
		fi
		
		if [[ $return_code -ne 0 ]]; then
			## An error was encountered.
			## An error message should have been displayed.
			## But only here do we know the line number
			echo -e "$OSL_OUTPUT_STYLE_PROBLEM error line $line_count in file \"$compfile_path\" !$OSL_OUTPUT_STYLE_DEFAULT"
			## no need to parse further
			break
		fi
	done < "$compfile_path"
	
	CVM_debug "<<< parsing compfile \"$compfile_path\" done."
	
	## restore for recursivity
	CVM_COMPFILE_current_parsed_file=$previous_parsed_file
	CVM_COMPFILE_current_component=$previous_parsed_component
	CVM_debug "(back to parsing of compfile \"$CVM_COMPFILE_current_parsed_file\")"

	return $return_code
}

CVM_COMPFILE_parse_compfile_line()
{
	local line="$*"
	local return_code=0 # OK until found otherwise
	CVM_debug "parsing compfile line \"$line\"..."
	
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
	"c++vm_minimum_required_version")
		CVM_COMPFILE_process_line_minimum_required_version "$line_data"
		return_code=$?
		;;
	### ...
	"language")
		CVM_COMPFILE_process_line_language "$line_data"
		return_code=$?
		;;
	### ...
	"include")
		CVM_COMPFILE_process_line_include "$line_data"
		return_code=$?
		;;
	### ...
	"require")
		CVM_COMPFILE_process_line_require "$line_data"
		return_code=$?
		;;
	### ...
	"stub")
		CVM_COMPFILE_process_line_stub "$line_data"
		return_code=$?
		## means that this file contains no more useful information
		break ## we can stop here
		;;
	### ??? command not recognized
	*)
		OSL_OUTPUT_warn "unrecognized command : \"$line_cmd\"..."
		#return_code=1 ## error
		;;
	esac

	OSL_INIT_restore_default_IFS
	
	return $return_code
}


CVM_COMPFILE_process_line_minimum_required_version()
{
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing compfile cmd minimum_required_version..."
	
	IFS=","
	typeset -a line_data_comma_splitted=( $line_data )
	#CVM_debug "# : ${#line_data_comma_splitted[@]}"
	#CVM_debug "@ : ${line_data_comma_splitted[@]}"
	#CVM_debug "0 : ${line_data_comma_splitted[0]}"
	#CVM_debug "1 : ${line_data_comma_splitted[1]}"
	#CVM_debug "2 : ${line_data_comma_splitted[2]}"

	## just check that there is only one param
	if [[ ${#line_data_comma_splitted[@]} -ne 1 ]]; then
		OSL_OUTPUT_display_error_message "syntax error : c++vm_minimum_required_version cmd takes one and only one parameter"
	else
		local required_version=$(OSL_STRING_trim ${line_data_comma_splitted[0]})
		## check against current version
		OSL_VERSION_test_greater_or_equal $CVM_VERSION $required_version
		if [[ $? -ne 0 ]]; then
			## version requirement not met
			OSL_OUTPUT_display_error_message "C++VM version requirement not met ! Please upgrade to at last : $required_version"
			## return code stays NOK
		else
			return_code=0 ## OK
		fi
	fi
	
	return $return_code
}

CVM_COMPFILE_process_line_language()
{
	# nothing for now, no warning
	do_nothing=1
}

CVM_COMPFILE_process_line_include()
{
	OSL_OUTPUT_warn_not_implemented "include"
}

CVM_COMPFILE_process_line_stub()
{
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing compfile cmd stub..."
	
	## add the requirement to the current component if needed
	CVM_COMP_SELECTION_add_component_stub_info_if_needed  $CVM_COMPFILE_current_component
	return_code=$?
	
	return $return_code
}


CVM_COMPFILE_process_line_require()
{
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing compfile cmd require..."
	
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
	else
		## now decode parameters
		local raw_component_id=$(OSL_STRING_trim ${line_data_comma_splitted[0]})
		local component_id=$(OSL_STRING_to_lower $raw_component_id)
		
		## add the requirement to the current component if needed
		CVM_COMP_SELECTION_add_component_dependency_if_needed  $CVM_COMPFILE_current_component  $component_id
		
		## now parse additional arguments
		local required_version="N/A" ## by default
		local component_source="integrated" ## by default
		## TODO
		
		## add the required component if needed
		CVM_COMP_SELECTION_add_if_needed $component_id
		local comp_just_created=$?
		if [[ $comp_just_created -eq 1 ]]; then
			## add required component own deps
			## this is complex, offload it
			CVM_COMPFILE_process_component $component_id $component_source
			return_code=$?
		else
			return_code=0 ## all is fine
		fi
		
	fi ## param OK
	
	return $return_code
}

CVM_COMPFILE_process_component()
{
	local component_id=$1
	local component_source=$2
	local return_code=1 # error by default
	
	CVM_debug "processing subcomponent \"$component_id\"..."
	
	CVM_COMPONENT_find_best_matching_component $component_id
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

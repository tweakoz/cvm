#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the parsing of compfiles, especially the root one
##
## This file is not meant to be executed, only sourced :
##   source cvm_lib_parse.sh

## REM : required includes are in main file



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
			echo -e "$OSL_OUTPUT_STYLE_PROBLEM error related to line $line_count of file \"$compfile_path\" !$OSL_OUTPUT_STYLE_DEFAULT"
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

#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the parsing of compfiles, especially the root one
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
	local rsrc_id=$CVM_COMP_SELECTION_DIR_NAME
	local rsrc_dir=.
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"
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
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		## everything went OK
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
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
	#"stub")
	#	CVM_COMPFILE_process_line_stub "$line_data"
	#	return_code=$?
	#	## means that this file contains no more useful information
	#	break ## we can stop here
	#	;;
	### ??? command not recognized
	*)
		## don't care : it must be one of the many install commands
		do_nothing=1
		##OSL_OUTPUT_warn "unrecognized command : \"$line_cmd\"..."
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
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing compfile cmd \"language\"..."
	
	OSL_OUTPUT_warn_not_implemented "language"
	#return_code=$?
	
	return $return_code
}


CVM_COMPFILE_process_line_include()
{
	local line_data=$1
	local return_code=1 # error by default
	
	CVM_debug "processing compfile cmd \"include\"..."
	
	OSL_OUTPUT_warn_not_implemented "include"
	#return_code=$?
	
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
		local component_source="" ## for now
		local min_version_authorized="" ## for now
		local max_version_authorized="" ## for now
		local exact_version_required="" ## for now
		# to split lines along comma, we must change the IFS
		IFS=',' # this makes IFS the comma
		local count=0
		return_code=0 # ok until found otherwise
		for raw_block in $line_data; do
			#CVM_debug "raw_block = $raw_block"
			# now we split along semicolon
			IFS=':' # this makes IFS the comma
			typeset -a key_value=( $raw_block )
			IFS=',' # this makes IFS a comma again
			local key=$(OSL_STRING_trim "${key_value[0]}")
			local value=$(OSL_STRING_trim "${key_value[1]}")
			count=$(expr $count + 1)
			if [[ $count -eq 1 ]]; then
				## skip this one
				do_nothing=1
			else
				CVM_debug "parsing require option ($key, $value)"
				case $key in
				## explicit version requirement
				"version")
					CVM_COMPFILE_process_generic_version_requirement "$value" "$min_version_authorized" "$max_version_authorized" "$exact_version_required"
					return_code=$?
					#CVM_debug "rv $return_code"
					if [[ $return_code -eq 11 ]]; then
						min_version_authorized=$return_value
						return_code=0 ## OK again
					elif [[ $return_code -eq 22 ]]; then
						max_version_authorized=$return_value
						return_code=0 ## OK again
					elif [[ $return_code -eq 33 ]]; then
						exact_version_required=$return_value
						return_code=0 ## OK again
					else
						OSL_OUTPUT_display_error_message "couldn't understand version requirement : $value"
						return_code=1 ## error
						break
					fi
					;;
				## add a dependency not enabled by default
				"require")
					CVM_COMPFILE_process_additional_dependency "$value"
					return_code=$?
					#CVM_debug "rv $return_code"
					if [[ $return_code -ne 0 ]]; then
						OSL_OUTPUT_display_error_message "couldn't understand dependency : $value"
						return_code=1 ## error
						break
					fi
					;;
				## shortcut to avoid download
				"archive_path")
					CVM_COMPFILE_process_archive_path "$component_id" "$value"
					return_code=$?
					#CVM_debug "rv $return_code"
					if [[ $return_code -ne 0 ]]; then
						OSL_OUTPUT_display_error_message "couldn't understand archive path : $value"
						return_code=1 ## error
						break
					fi
					;;
				*)
					## unrecognized
					OSL_OUTPUT_display_error_message "unrecognized option : $key"
					return_code=1 ## error
					break
					;;
				esac
			fi
		done
		OSL_INIT_restore_default_IFS

		if [[ $return_code -ne 0 ]]; then
			return $return_code
		fi
		
		## add the required component if needed
		CVM_COMP_SELECTION_add_if_needed $component_id
		CVM_COMP_SELECTION_test_if_already_selected $component_id
		if [[ $? -ne 0 ]]; then
			## add required component own deps
			## this is complex, offload it
			CVM_COMP_SELECTION_select_component $component_id "$component_source" "$min_version_authorized" "$max_version_authorized" "$exact_version_required"
			return_code=$?
		else
			return_code=0 ## everything is fine
		fi
		
	fi ## param OK
	OSL_INIT_restore_default_IFS

	return $return_code
}


CVM_COMPFILE_process_archive_path()
{
	local component_id=$1
	local path_info=$2
	local return_code=1

	CVM_debug "CVM_COMPFILE_process_archive_path $component_id -> $path_info"

	## add the required component if needed
	CVM_COMP_SELECTION_add_if_needed "$component_id"

	## add the needed infos
	local line=""
	line="src_obtention_mode       archive"
	CVM_COMP_SELECTION_add_component_info_if_needed  "$component_id"  "$line"
	line="archive_obtention_mode   path"
	CVM_COMP_SELECTION_add_component_info_if_needed  "$component_id"  "$line"
	line="archive_path             $path_info"
	CVM_COMP_SELECTION_add_component_info_if_needed  "$component_id"  "$line"
	return_code=$?

	return $return_code
}


CVM_COMPFILE_process_additional_dependency()
{
	local dependency_info=$1
	local return_code=1

	CVM_debug "CVM_COMPFILE_process_additional_dependency $component_id -> $dependency_info"

	## add the required component if needed
	CVM_COMP_SELECTION_add_if_needed "$component_id"

	## add the needed infos
	local line="require $dependency_info"
	CVM_COMP_SELECTION_add_component_info_if_needed  "$component_id"  "$line"
	
	return_code=$?

	return $return_code
}


CVM_COMPFILE_process_generic_version_requirement()
{
	local version_requirement=$1
	local min_version_authorized=$2
	local max_version_authorized=$3
	local exact_version_required=$4
	local return_code=1 # error by default (XXX FOR THIS FUNC, SPECIAL MEANING)
	return_value="error" # error by default

	CVM_debug "CVM_COMPFILE_process_generic_version_requirement \"$version_requirement\" with $min_version_authorized/$exact_version_required/$max_version_authorized..."

	local vr_length=${#version_requirement}
	local possible_plus_pos=$(expr $vr_length - 1)
	CVM_debug "\"$version_requirement\" ($vr_length) ~?${version_requirement:0:1} +?${version_requirement:$possible_plus_pos:1}"
	if [[ "${version_requirement:0:1}" == "~" ]]; then
		OSL_OUTPUT_warn_not_implemented "CVM_COMPFILE_process_version_requirement ~"
		##[[ $return_code -eq 0]] && return_code=22
	elif [[ "${version_requirement:$possible_plus_pos:1}" == "+" ]]; then
		CVM_COMPFILE_process_min_version_requirement "${version_requirement:0:$possible_plus_pos}" "$min_version_authorized"
		return_code=$?
		if [[ $return_code -eq 0 ]]; then
			return_code=11
		fi
		## REM return value was changed by call above
	else
		## this is an explicit version
		CVM_COMPFILE_process_explicit_version_requirement "$version_requirement" "$exact_version_required"
		return_code=$?
		if [[ $return_code -eq 0 ]]; then
			return_code=33
		fi
		## REM return value was changed by call above
	fi

	return $return_code
}


CVM_COMPFILE_process_explicit_version_requirement()
{
	local explicit_required_version=$1
	local previous_explicit_required_version=$2
	local return_code=1 # error by default
	return_value="error"

	CVM_debug "CVM_COMPFILE_process_explicit_version_requirement \"$explicit_required_version\"..."

	if [[ -z "$previous_explicit_required_version" ]]; then
		## no conflict, OK
		return_code=0
		return_value="$explicit_required_version"
	elif [[ "$previous_explicit_required_version" == "$explicit_required_version" ]]; then
		## no conflict, OK
		return_code=0
		return_value="$explicit_required_version"
	else
		## conflict, NOK
		OSL_OUTPUT_display_error_message "Conflicting explicit version requirements : $explicit_required_version vs. $previous_explicit_required_version"
		## ret code stays false
	fi

	return $return_code
}


CVM_COMPFILE_process_min_version_requirement()
{
	local min_required_version=$1
	local previous_min_required_version=$2
	local return_code=1 # error by default
	return_value="error"

	CVM_debug "CVM_COMPFILE_process_min_version_requirement \"$min_required_version\"..."

	if [[ -z "$previous_min_required_version" ]]; then
		## no conflict, OK
		return_code=0
		return_value="$min_required_version"
	else
		OSL_VERSION_test_smaller_or_equal "$min_required_version" "$previous_min_required_version"

		if [[ $? -eq 0 ]]; then
			## new value is smaller or equal -> we keep the bigger
			return_code=0
			return_value="$previous_min_required_version"
		else
			## new value replace former
			return_code=0
			return_value="$min_required_version"
		fi
	fi

	CVM_debug "  -> $return_value"

	return $return_code
}

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

	## XXX make more subtile
	#rm -rf $CVM_COMP_INSTALL_FINAL_DIR_NAME
	
	mkdir $CVM_COMP_INSTALL_FINAL_DIR_NAME
	mkdir $CVM_COMP_INSTALL_FINAL_DIR_NAME/include
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
	
	CVM_COMP_INSTALL_ensure_loaded_component_is_installed  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
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


CVM_COMP_INSTALL_get_value_from_cached_component_for()
{
	local key=$1
	local return_code=1 # error/not exist by default
	return_value=""
	
	CVM_debug "looking for value of key \"$key\" in current component data..."

# to split lines along \n, we must change the IFS
	IFS='
' # this makes IFS a newline
	for raw_line in $CVM_COMP_INSTALL_current_component_data; do
		local line=$(OSL_STRING_trim "$raw_line")
		#echo "$line"
		IFS=" "
		## REM : -a = array, splitted along IFS
		typeset -a line_space_splitted=( $line )
		#CVM_debug "- : ${line_space_splitted}"
		#CVM_debug "0 : ${line_space_splitted[0]}"
		#CVM_debug "1 : ${line_space_splitted[1]}"
		#CVM_debug "2 : ${line_space_splitted[2]}"
		IFS='
' # this makes IFS a newline again

		local line_key=${line_space_splitted[0]}
		if [[ "$line_key" == "$key" ]]; then
			## found
			return_value=$(OSL_STRING_trim "${line#$key}")
			return_code=0
			CVM_debug " -> found, $key=\"$return_value\""
			break
		fi
	done
	OSL_INIT_restore_default_IFS
	
	if [[ $return_code -ne 0 ]]; then
		## not found
		CVM_debug " -> not found."
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_is_installed()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	echo "* ensuring that component \"$component_id\" is installed with version \"${component_version#$component_id.}\"..."

	#CVM_debug_multi $CVM_COMP_INSTALL_current_component_data
	
	## first check install mode
	CVM_COMP_INSTALL_get_value_from_cached_component_for "install_mode"
	return_code=1 # error/not exist by default
	case $return_value in
	### do nothing
	"do_nothing")
		## well...
		return_code=0 ## OK
		;;
	### install via apt
	"apt")
		CVM_COMP_INSTALL_ensure_loaded_component_is_installed_via_apt "$component_id" "$component_version"
		return_code=$?
		;;
	### build it !
	"build")
		CVM_COMP_INSTALL_ensure_loaded_component_is_built_and_installed "$component_id" "$component_version"
		return_code=$?
		;;
	### no info
	"")
		OSL_EXIT_abort_execution_with_message "Can't find how to install given package..."
		## return_code stays NOK
		;;
	### any other command
	*)
		OSL_EXIT_abort_execution_with_message "Unknown install method : \"$return_value\""
		## return_code stays NOK
		;;
	esac

	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_is_installed_via_apt()
{
	local return_code=1 # error/not exist by default

	OSL_OUTPUT_warn_not_implemented "CVM_COMP_INSTALL_ensure_loaded_component_is_installed_via_apt"
	
	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_is_built_and_installed()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* ensuring that component \"$component_version\" is built and installed..."

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_INSTALL_RSRC_ID_PART
	OSL_RSRC_check "$CVM_COMP_INSTALL_FINAL_DIR_NAME" $rsrc_id
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi

	## first ensure that component is built
	CVM_COMP_INSTALL_ensure_loaded_component_is_built "$component_id" "$component_version"
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		return 1
	fi
	
	## now we can install
	
	OSL_RSRC_begin_managed_write_operation "$CVM_COMP_INSTALL_FINAL_DIR_NAME" "$rsrc_id"

	## first check install mode
	local install_mode="error"
	CVM_COMP_INSTALL_get_value_from_cached_component_for "post_build_install_mode"
	return_code=$?
	if [[ $return_code -eq 0 ]]; then
		## explicitely given : we obey
		install_mode=$return_value
	else
		## try to infer it ourselves
		CVM_COMP_INSTALL_get_value_from_cached_component_for "build_mode"
		return_code=$?
		case $return_value in
		"cmake")
			install_mode="make_install"
			;;
		"make")
			install_mode="auto"
			;;
		### anything else
		*)
			## ??? don't know !
			OSL_OUTPUT_display_error_message "Can't guess how to install (after build) given component..."
			;;
		esac
	fi
	CVM_debug "* component \"$component_version\" install (after build) mode : $install_mode"

	return_code=1 # error
	case $install_mode in
	"make_install")
		## let's do it
		local prev_wd=$(pwd)
		local build_dir="$(CVM_COMPONENT_get_component_build_dir $component_version)"
		cd "$build_dir"
		make install
		return_code=$?
		## back to prev dir
		cd "$prev_wd"
		;;
	"auto")
		## this one is clever
		## we will copy all .h and .a/.so in their expected dir
		local build_dir="$(CVM_COMPONENT_get_component_build_dir $component_version)"
		
		local include_dir="$(CVM_COMPONENT_get_component_include_dir $component_version)"
		mkdir -p "$include_dir"
		for file in `find -P "$build_dir" \( -name "*.h" -o -name "*.hxx" -o -name "*.hpp" -o -name "*.H" \) -type f`; do
			echo "$file"
			cp "$file" "$include_dir"
		done
		
		local lib_dir="$(CVM_COMPONENT_get_component_lib_dir $component_version)"
		mkdir -p "$lib_dir"
		for file in `find -P "$build_dir" \( -name "*.a" -o -name "*.so" \) -type f`; do
			echo "$file"
			cp "$file" "$lib_dir"
		done
		
		local bin_dir="$(CVM_COMPONENT_get_component_include_dir $component_version)"
		mkdir -p "$bin_dir"

		## I'm lazy...
		return_code=0
		;;
	### anything else
	*)
		OSL_OUTPUT_display_error_message "Unknown install (after build) method : \"$install_mode\""
		## return_code stays NOK
		;;
	esac

	if [[ $return_code -ne 0 ]]; then
		OSL_RSRC_end_managed_write_operation_with_error "$CVM_COMP_INSTALL_FINAL_DIR_NAME" $rsrc_id
	else
		OSL_RSRC_end_managed_write_operation "$CVM_COMP_INSTALL_FINAL_DIR_NAME" $rsrc_id
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to \"$component_version\" !"
			return_code=1 # error
		fi
	fi

	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "error while installing (after build) component \"$component_version\"..."
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_is_built()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* ensuring that component \"$component_version\" is built..."

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_BUILD_RSRC_ID_PART
	local rsrc_dir="$CVM_COMP_INSTALL_FINAL_DIR_NAME/build"
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi

	## first we need the src
	CVM_COMP_INSTALL_ensure_loaded_component_src_are_available "$component_id" "$component_version"
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		return 1
	fi
	
	## now we can build
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"

	CVM_COMP_INSTALL_get_value_from_cached_component_for "build_mode"
	return_code=1 # error/not exist by default
	case $return_value in
	### basic make
	"make")
		## let's do it
		local prev_wd=$(pwd)
		local build_dir="$(CVM_COMPONENT_get_component_build_dir $component_version)"
		cd "$build_dir"
		make
		return_code=$?
		## back to prev dir
		cd "$prev_wd"
		;;
	### no info
	"")
		OSL_OUTPUT_display_error_message "Can't find how to build given component..."
		## return_code stays NOK
		;;
	### anything else
	*)
		OSL_OUTPUT_display_error_message "Unknown build method : \"$return_value\""
		## return_code stays NOK
		;;
	esac

	if [[ $return_code -ne 0 ]]; then
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to \"$component_version\" !"
			return_code=1 # error
		fi
	fi

	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "error while building component \"$component_version\"..."
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_src_are_available()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* ensuring that component \"$component_version\" src are available..."

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_SRC_RSRC_ID_PART
	local rsrc_dir="$CVM_COMP_INSTALL_FINAL_DIR_NAME/build"
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi

	## in any case, we need shared src
	CVM_COMP_INSTALL_ensure_loaded_component_shared_src_are_available "$component_id" "$component_version"
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		return 1
	fi

	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"

	## do we have "in source build" or "out of source build" ?
	CVM_COMP_INSTALL_compute_loaded_component_build_src_dir "$component_id" "$component_version"
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		return 1
	fi
	local build_src_dir=$return_value
	local oos_src_dir="$(CVM_COMPONENT_get_component_shared_src_dir $component_version)"
	if [[ "$build_src_dir" == "$oos_src_dir" ]]; then
		## OOS build
		## do nothing
		return_code=0
	else
		## IS build
		## we make a full copy of the source
		cp -r "$oos_src_dir" "$build_src_dir"
		return_code=$?
	fi

	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "error while making component \"$component_version\" src are available !"
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_compute_loaded_component_build_src_dir()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	return_value="error"
	
	CVM_debug "* computing component \"$component_version\" build src dir..."

	## do we have "in source build" or "out of source build" ?
	local out_of_source_build_available=false
	CVM_COMP_INSTALL_get_value_from_cached_component_for "out_of_source_build_available"
	return_code=$?
	if [[ $return_code -eq 0 ]]; then
		## explicitely given : we obey
		out_of_source_build_available=$return_value
	else
		## try to infer it ourselves
		CVM_COMP_INSTALL_get_value_from_cached_component_for "build_mode"
		return_code=$?
		case $return_value in
		"cmake")
			## yes, this build mode allows OOS build
			out_of_source_build_available=true
			;;
		### anything else
		*)
			## safety, don't enable OOS build
			do_nothing=1
			;;
		esac
	fi
	CVM_debug "* component \"$component_version\" allows OOS build : $out_of_source_build_available"

	## so...
	return_code=1 # error
	case $out_of_source_build_available in
	"true")
		return_value="$(CVM_COMPONENT_get_component_shared_src_dir $component_version)"
		return_code=0
		;;
	"false")
		return_value="$(CVM_COMPONENT_get_component_build_dir $component_version)"
		return_code=0
		;;
	### anything else
	*)
		OSL_OUTPUT_display_error_message "error reading OOS build mode !"
		##
		;;
	esac
	
	CVM_debug "* component \"$component_version\" build dir is : $return_value"

	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_shared_src_are_available()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* ensuring that component \"$component_version\" SHARED src are available..."

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_SRC_RSRC_ID_PART
	local rsrc_dir="$CVM_SRC_DIR"
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi


	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"
	
	## how do we get the src ??
	CVM_COMP_INSTALL_get_value_from_cached_component_for "src_obtention_mode"
	return_code=1 # error/not exist by default
	case $return_value in
	### from a git repo
	"git")
		OSL_OUTPUT_warn_not_implemented "git"
		return_code=1 # error
		;;
	### from a svn repo
	"svn")
		OSL_OUTPUT_warn_not_implemented "svn"
		return_code=1 # error
		;;
	### from an archive
	"archive")
		CVM_COMP_INSTALL_ensure_loaded_component_shared_archive_is_available "$component_id" "$component_version"
		if [[ $? -eq 0 ]]; then
			## now we must unpack the archive

			## a little trick to handle archives which don't unpack in expected dir
			CVM_COMP_INSTALL_get_value_from_cached_component_for "unexpected_archive_unpack_dir"
			local unexpected_archive_unpack_dir="$return_value"
			## note : don't care if none set, then will be ignored
			
			OSL_ARCHIVE_unpack_to "$(CVM_COMPONENT_get_component_shared_archive_path $component_version)" "$(CVM_COMPONENT_get_component_shared_src_dir $component_version)" "$unexpected_archive_unpack_dir"
			return_code=$?
		fi
		;;
	### directly from a path
	"path")
		## first ensure that component is built
		OSL_OUTPUT_warn_not_implemented "path"
		return_code=1 # error
		;;
	### no info
	"")
		OSL_OUTPUT_display_error_message "Can't find how to get given component source code..."
		## return_code stays NOK
		;;
	### anything else
	*)
		OSL_OUTPUT_display_error_message "Unknown source obtention method : \"$return_value\""
		## return_code stays NOK
		;;
	esac

	if [[ $return_code -ne 0 ]]; then
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to \"$component_version\" !"
			return_code=1 # error
		fi
	fi

	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_shared_archive_is_available()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* ensuring that component \"$component_version\" shared archive is available..."

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_ARCHIVE_RSRC_ID_PART
	local rsrc_dir="$CVM_ARCHIVES_DIR"
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi


	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"
	
	## how do we get the archive ??
	CVM_COMP_INSTALL_get_value_from_cached_component_for "archive_obtention_mode"
	return_code=1 # error/not exist by default
	case $return_value in
	### from the web
	"download")
		OSL_OUTPUT_warn_not_implemented "download"
		return_code=1 # error
		;;
	### directly from a path
	"path")
		CVM_COMP_INSTALL_get_value_from_cached_component_for "archive_path"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Can't find path of given component archive..."
		else
			local archive_path=$return_value
			if ! [[ -f "$archive_path" ]]; then
				OSL_OUTPUT_display_error_message "Can't find given component archive path : $archive_path"
			else
				mkdir -p "$CVM_ARCHIVES_DIR/$component_version"
				cp "$archive_path" "$CVM_ARCHIVES_DIR/$component_version"
				return_code=$?
			fi
		fi
		;;
	### no info
	"")
		OSL_OUTPUT_display_error_message "Can't find how to get given component archive..."
		## return_code stays NOK
		;;
	### anything else
	*)
		OSL_OUTPUT_display_error_message "Unknown archive obtention method : \"$return_value\""
		## return_code stays NOK
		;;
	esac

	if [[ $return_code -ne 0 ]]; then
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
		OSL_OUTPUT_display_error_message "Can't find given component archive path : $archive_path"
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to \"$component_version\" !"
			return_code=1 # error
		fi
	fi

	if [[ $return_code -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "couldn't obtain component \"$component_version\" archive..."
	else
		CVM_debug "* component \"$component_version\" shared archive obtained successfully."
	fi

	return $return_code
}


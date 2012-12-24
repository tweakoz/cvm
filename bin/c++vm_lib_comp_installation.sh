#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   the installation of a component
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
	
	## We will now rebuild the component installation
	## This is a complex shared rsrc
	local rsrc_id="components_installation"
	local rsrc_dir=.
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"
	
	## XXX make more subtile
	#rm -rf $CVM_COMP_INSTALL_FINAL_DIR_NAME
	#echo "" > "$CVM_COMP_INSTALL_FINAL_DIR_NAME/$CVM_DEFAULT_ENV_FILE_NAME"
	
	mkdir -p "$CVM_COMP_INSTALL_FINAL_DIR_NAME"
	mkdir -p "$CVM_COMP_INSTALL_BUILD_DIR_NAME"
	mkdir -p "$CVM_COMP_INCLUDES_FOR_INDEXER_DIR_NAME"

#	mkdir -p $CVM_COMP_INSTALL_FINAL_DIR_NAME/include
#	mkdir -p $CVM_COMP_INSTALL_FINAL_DIR_NAME/build
#	mkdir -p $CVM_COMP_INSTALL_FINAL_DIR_NAME/bin
#	mkdir -p $CVM_COMP_INSTALL_FINAL_DIR_NAME/lib
	
	## take up to where we were
	CVM_COMPSET_update_environment_vars_with_current_compset
	
	## start with root component
	CVM_COMP_INSTALL_parse_compselfile_for_component $CVM_ROOT_COMPONENT_NAME
	return_code=$?
	
	if [[ $return_code -ne 0 ]]; then
		## error during file parsing
		## An error message should already have been displayed.
		OSL_OUTPUT_display_error_message "Upgrade failed..."
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		## everything went OK
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
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
	### command not recognized --> must be an installation instruction, ignore
	*)
		do_nothing=1
		;;
	esac

	OSL_INIT_restore_default_IFS
	
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
		CVM_COMP_INSTALL_ensure_component_installed $component_id
		return_code=$?
	fi ## param OK ?
	
	CVM_debug "require line processing done : $return_code"
	CVM_COMP_INSTALL_last_seen_selected_version=$old_last_seen_selected_version
	
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


CVM_COMP_INSTALL_ensure_component_installed()
{
	local component_id=$1
	local return_code=1 # error/not exist by default
	
	CVM_debug "ensuring that component \"$component_id\" is fully installed..."
	
	## check if this component is already installed properly
	local rsrc_id=$component_id.$CVM_COMP_RSRC_ID_PART
	local rsrc_dir=$CVM_COMP_INSTALL_FINAL_DIR_NAME
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi

	## parse this component own selection file
	## in order to install its dependencies first
	CVM_COMP_INSTALL_parse_compselfile_for_component $component_id
	return_code=$?
	if [[ $return_code -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "dependencies failed for component \"$component_id\"..."
		## return code stays NOK
	else
		## then install the component itself
		local OSlmomd_bkp=$OSL_RSRC_state
		OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id" "CVM_COMP_INSTALL_ensure_component_installed"
		
		CVM_debug "installing component : $component_id / $CVM_COMP_INSTALL_last_seen_selected_version"

		CVM_COMP_INSTALL_load_component_data  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
		return_code=$?
		if [[ $return_code -ne 0 ]]; then
			## error during file parsing
			## An error message should already have been displayed.
			OSL_OUTPUT_display_error_message "Component data read failed......"
		else
			CVM_COMP_INSTALL_ensure_loaded_component_is_installed  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
			return_code=$?
		fi

		## post processing
		if [[ $return_code -eq 0 ]]; then
			CVM_COMP_INSTALL_collect_env_infos_for_freshly_installed_component  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
			return_code=$?
		fi
		if [[ $return_code -eq 0 ]]; then
			CVM_COMP_INSTALL_collect_includes_for_freshly_installed_component  $component_id  $CVM_COMP_INSTALL_last_seen_selected_version
			return_code=$?
		fi
			
		if [[ $return_code -ne 0 ]]; then
			## An error message should already have been displayed.
			OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
		else
			## everything went OK
			OSL_OUTPUT_display_success_message "Install of $component_id done"
			OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
			if [[ $? -ne 0 ]]; then
				OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
				return_code=1 # error
			fi
		fi
		OSL_RSRC_state=$OSlmomd_bkp
	fi ## dependencies

	if [[ $return_code -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "Install failed..."
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_load_component_data()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "loading component data for $component_id..."

	## reset data
	CVM_COMP_INSTALL_current_component_data=""

	## first parse compselfile for interesting data
	## or overrides
	local COMPSEL_FILE=$(CVM_COMP_SELECTION_get_compfile_for $component_id)
	CVM_COMPFILE_parse_compfile "$COMPSEL_FILE" $component_id "CVM_COMP_INSTALL_parse_line_load_compfile_data"
	if [[ $? -ne 0 ]]; then
		## an error message was already displayed
		exit 1
	fi
	
	## then parse component own file
	CVM_COMPONENT_find_known_component_dir $component_id
	if [[ $? -ne 0 ]]; then
		## an error message was already displayed
		exit 1
	fi
	
	local expected_compfile="$return_value/$component_version"
	if ! [[ -f "$expected_compfile" ]]; then
		OSL_OUTPUT_display_error_message "required known component version \"$component_version\" couldn't be found... This should not happen ! (internal error)"
		return_code=1 # error
	else
		## and start parsing, for default component
		CVM_COMPFILE_parse_compfile "$expected_compfile" $component_id "CVM_COMP_INSTALL_parse_line_load_compfile_data"
		return_code=$?
	fi

	#echo "final component data :"
	#echo "------"
	#CVM_debug_multi $CVM_COMP_INSTALL_current_component_data
	#echo "------"
	
	return $return_code
}


CVM_COMP_INSTALL_collect_env_infos_for_freshly_installed_component()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "Storing env infos for $component_id..."

	local env_file="$CVM_COMP_INSTALL_FINAL_DIR_NAME/$CVM_DEFAULT_ENV_FILE_NAME"
	local lib_dir=$(CVM_COMPONENT_get_component_lib_dir "$component_version")
	lib_dir=$(readlink -f "$lib_dir")
	local bin_dir=$(CVM_COMPONENT_get_component_bin_dir "$component_version")
	bin_dir=$(readlink -f "$bin_dir")
	local inc_dir=$(CVM_COMPONENT_get_component_include_dir "$component_version")
	inc_dir=$(readlink -f "$inc_dir")
	
	if [[ -d "$lib_dir" ]]; then
		echo "OSL_PATHVAR_prepend_to_PLV_if_not_already_there  LD_LIBRARY_PATH \"$lib_dir\"" >> "$env_file"
		echo "OSL_PATHVAR_prepend_to_PLV_if_not_already_there  CMAKE_LIBRARY_PATH \"$lib_dir\"" >> "$env_file"
	fi

	if [[ -d "$bin_dir" ]]; then
		echo "OSL_PATHVAR_prepend_to_PLV_if_not_already_there  PATH            \"$bin_dir\"" >> "$env_file"
	fi

	if [[ -d "$inc_dir" ]]; then
		echo "OSL_PATHVAR_prepend_to_PLV_if_not_already_there  INCLUDE_PATH    \"$inc_dir\"" >> "$env_file"
		echo "OSL_PATHVAR_prepend_to_PLV_if_not_already_there  CMAKE_INCLUDE_PATH    \"$inc_dir\"" >> "$env_file"
	fi

	##CMAKE_PREFIX_PATH
	
	## apply what we just updated
	CVM_COMPSET_update_environment_vars_with_current_compset
	
	return_code=0
	
	return $return_code
}


CVM_COMP_INSTALL_collect_includes_for_freshly_installed_component()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* Linking includes for $component_id..."

	local comp_inc_dir=$(CVM_COMPONENT_get_component_include_dir "$component_version")
	comp_inc_dir=$(readlink -f "$comp_inc_dir")

	CVM_debug "  expected in : $comp_inc_dir..."
	if [[ -d "$comp_inc_dir" ]]; then
		local comp_name=$(CVM_COMPONENT_get_component_target_name "$component_id")
		
		local index_inc_dir="$CVM_COMP_INCLUDES_FOR_INDEXER_DIR_NAME/$comp_name"
#		index_inc_dir=$(readlink -f "$index_inc_dir")
		index_inc_dir=$(OSL_FILE_abspath "$index_inc_dir")
	
		CVM_debug "  target set to $index_inc_dir ($(pwd)/$CVM_COMP_INCLUDES_FOR_INDEXER_DIR_NAME/$comp_name)..."
		ln --symbolic "$comp_inc_dir" "$index_inc_dir"
		## don't care if it failed
	fi

	return_code=0
	
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
		echo "  -> done (nothing to do)"
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
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_APT_PKT_RSRC_ID_PART
	local rsrc_dir="$CVM_COMP_INSTALL_FINAL_DIR_NAME"
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
	if [[ $? -eq 0 ]]; then
		## rsrc is already OK' nothing to do
		CVM_debug "  -> this rsrc is already available."
		return 0
	fi

	## now we can install
	
	local OSlmomd_bkp=$OSL_RSRC_state
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"

	CVM_COMP_INSTALL_get_value_from_cached_component_for "apt_packets"
	return_code=$?
	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "Can't read apt packets given component archive..."
	else
		local apt_packets=$return_value
		sudo apt-get install --yes $apt_packets
		return_code=$?
	fi

	if [[ $return_code -ne 0 ]]; then
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
	fi
	OSL_RSRC_state=$OSlmomd_bkp

	OSL_OUTPUT_warn_not_implemented "TODO : collect env and includes !"
	
	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "error while installing component \"$component_version\" with apt-get install"
	fi
		
	return $return_code
}


CVM_COMP_INSTALL_ensure_loaded_component_is_built_and_installed()
{
	local component_id=$1
	local component_version=$2
	local return_code=1 # error/not exist by default
	
	CVM_debug "* ensuring that component \"$component_version\" is built and installed..."

	## chek rsrc
	local rsrc_id=$component_version.$CVM_COMP_INSTALLED_OBJS_RSRC_ID_PART
	local rsrc_dir="$CVM_COMP_INSTALL_FINAL_DIR_NAME"
	OSL_RSRC_check "$rsrc_dir" "$rsrc_id"
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
	
	local OSlmomd_bkp=$OSL_RSRC_state
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"

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
		local build_mode=$return_value
		case $build_mode in
		"cmake")
			install_mode="make_install"
			;;
		"autotools")
			install_mode="make_install"
			;;
		"make")
			install_mode="auto"
			;;
		"bjam")
			## for bjam, build and install are not separated
			install_mode="do_nothing"
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
	"do_nothing")
		## well...
		return_code=0
		;;
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
		## we will copy all .h and .a/.so to their expected dir
		local build_dir="$(CVM_COMPONENT_get_component_build_dir $component_version)"

		## first the libs
		local lib_dir="$(CVM_COMPONENT_get_component_lib_dir $component_version)"
		mkdir -p "$lib_dir"
		for file in `find -P "$build_dir" \( -name "*.a" -o -name "*.so" \) -type f`; do
			#echo "$file"
			cp "$file" "$lib_dir"
		done

		## then the headers
		## sligtly more complicated because we must maintain dir structure
		## or else #include "xxx/yyy.h" will not work
		local include_dir="$(CVM_COMPONENT_get_component_include_dir $component_version)"
		mkdir -p "$include_dir"
		# 1st pass : find root dir
		local header_found=0
		local root_dir=""
		for file in `find -P . \( -name "*.h" -o -name "*.hxx" -o -name "*.hpp" -o -name "*.H" -o -name "*.h++" \) -type f`; do
			#echo "$file"
			local dir=`dirname "$file"`
			#CVM_debug "dir = $dir"
			if [[ $header_found -eq 0 ]]; then
				root_dir=$dir
				#CVM_debug "include root dir is now : $root_dir"
			else
				OSL_FILE_find_common_path "$root_dir" "$dir"
				root_dir=$return_value
				#CVM_debug "include root dir is now : $root_dir"
			fi
			header_found=1
		done
		# 2nd pass : header copy with structure preseved
		if [[ $header_found -ne 0 ]]; then
			CVM_debug "include root dir = $root_dir"
			for file in `find -P . \( -name "*.h" -o -name "*.hxx" -o -name "*.hpp" -o -name "*.H" -o -name "*.h++" \) -type f`; do
				#echo "$file"
				local dir=`dirname "$file"`
				OSL_FILE_find_relative_path "$root_dir" "$dir"
				local dst=$include_dir/$return_value/$(basename "$file")
				CVM_debug "copying include file $file to $dst..."
				mkdir -p `dirname "$dst"`
				cp "$file" "$dst"
				#cp "$file" "$include_dir"
			done
		fi
		## back to prev dir

		local bin_dir="$(CVM_COMPONENT_get_component_bin_dir $component_version)"
		#mkdir -p "$bin_dir"

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
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
	fi
	OSL_RSRC_state=$OSlmomd_bkp

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
	local rsrc_id=$component_version.$CVM_COMP_OBJS_RSRC_ID_PART
	local rsrc_dir="$CVM_COMP_INSTALL_BUILD_DIR_NAME"
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

	
	CVM_COMPONENT_find_known_component_dir $component_id
	if [[ $? -ne 0 ]]; then
		## an error message was already displayed
		return 1
	fi
	local component_definition_dir="$return_value"



	## now we can build
	local OSlmomd_bkp=$OSL_RSRC_state
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"


		
	CVM_COMP_INSTALL_get_value_from_cached_component_for "build_mode"
	local build_mode=$return_value
	return_code=1 # error/not exist by default
	case $build_mode in
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
	### the great cmake
	"cmake")
		## let's do it
		local prev_wd=$(pwd)
		local build_dir="$(CVM_COMPONENT_get_component_build_dir $component_version)"
		rm -rf "$build_dir"
		mkdir "$build_dir"
		local prefix="$(pwd)/$(CVM_COMPONENT_get_component_prefix $component_version)"
		prefix=$(readlink -f "$prefix")
		cd "$build_dir"
		CVM_COMP_INSTALL_compute_loaded_component_build_src_dir $component_id $component_version
		local src_dir=$return_value
		#pwd
		#ls
		cmake --version
		## additional options ?
		CVM_COMP_INSTALL_get_value_from_cached_component_for "cmake_additional_options"
		local cmake_additional_options=$return_value
		if [[ -n "$cmake_additional_options" ]]; then
			## 
			cmake_additional_options=$(CVM_COMP_INSTALL_substitute_keywords "$cmake_additional_options" "$prefix")
		fi
		echo "cmake -Wdev $src_dir -DCMAKE_INSTALL_PREFIX:PATH=$prefix $cmake_additional_options"
		cmake -Wdev "$src_dir" -DCMAKE_INSTALL_PREFIX:PATH="$prefix" $cmake_additional_options
		make
		return_code=$?
		## back to prev dir
		cd "$prev_wd"
		;;
	### used by boost
	"bjam")
		local prev_wd=$(pwd)
		local build_dir="$(pwd)/$(CVM_COMPONENT_get_component_build_dir $component_version)"
		build_dir=$(readlink -f "$build_dir")
		local prefix="$(pwd)/$(CVM_COMPONENT_get_component_prefix "$component_version")"
		prefix=$(readlink -f "$prefix")
		cd "$build_dir"
		echo "* configuring bjam... (prefix : $prefix)"
		## is this standard or boost-specific ?
		./bootstrap.sh --with-libraries=all --prefix="$prefix"
		return_code=$?
		if [[ $return_code -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "boost configuration failed"
		else
			# the --layout option is very important for Wt cmake to find the correct boost libs
			# hat tip : http://stackoverflow.com/a/6354570/587407
			echo "* compiling via bjam (build-dir : $build_dir)"
			./b2 install --layout=tagged --without-mpi --prefix="$prefix" --build-dir="$build_dir"
			return_code=$?
		fi
		## back to prev dir
		cd "$prev_wd"
		;;
	### the grand classic
	"autotools")
		## let's do it
		local prev_wd=$(pwd)
		local prefix="$(pwd)/$(CVM_COMPONENT_get_component_prefix $component_version)"
		prefix=$(readlink -f "$prefix")
		local build_dir="$(CVM_COMPONENT_get_component_build_dir $component_version)"
		cd "$build_dir"
		CVM_debug "./configure --prefix=$prefix"
		./configure --prefix="$prefix"
		return_code=$?
		if [[ $return_code -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "autotools configuration failed"
		else
			make
			return_code=$?
		fi
		## back to prev dir
		cd "$prev_wd"
		;;
	### other inhabitual ways
	"custom")
		local prev_wd=$(pwd)
		local build_dir="$(pwd)/$(CVM_COMPONENT_get_component_build_dir $component_version)"
		build_dir=$(readlink -f "$build_dir")
		local prefix="$(pwd)/$(CVM_COMPONENT_get_component_prefix "$component_version")"
		prefix=$(readlink -f "$prefix")
		cd "$build_dir"
		echo "* preparing custom... (prefix : $prefix) (build-dir : $build_dir)"
		CVM_COMP_INSTALL_get_value_from_cached_component_for "custom_build_script"
		local custom_build_script="$component_definition_dir/$return_value"
		if [[ -z "$return_value" ]]; then
			## no custom script -> can't do anything !
			OSL_OUTPUT_display_error_message "build script could not be read..."
		elif ! [[ -f "$custom_build_script" ]]; then
			OSL_OUTPUT_display_error_message "build script could not be found at $custom_build_script"
		else
			"$custom_build_script" "$prefix" ""
			return_code=$?
			if [[ $return_code -ne 0 ]]; then
				OSL_OUTPUT_display_error_message "build script failed"
			fi
		fi
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
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
	fi
	OSL_RSRC_state=$OSlmomd_bkp

	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "error while building component \"$component_version\"..."
	fi
	
	return $return_code
}


CVM_COMP_INSTALL_substitute_keywords()
{
	local string_to_substitute=$1
	local prefix=$2
	local result_string=$string_to_substitute # for now

	#CVM_debug "* substituting \"$string_to_substitute\"..."

	result_string=`echo "$result_string" | sed s!{{dir_result}}!$prefix!g`

	#CVM_debug "  --> substitution result \"$result_string\"."

	echo "$result_string"
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
	
	CVM_debug "* component \"$component_version\" src dir for build is : $return_value"

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
	local rsrc_dir="$CVM_COMP_INSTALL_BUILD_DIR_NAME"
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

	local OSlmomd_bkp=$OSL_RSRC_state
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
		#CVM_debug "* out-of source build..."
		return_code=0
	else
		## IS build
		## we make a full copy of the source
		CVM_debug "* copying src for in-source build..."
		cp -r "$oos_src_dir" "$build_src_dir"
		return_code=$?
	fi
	
	if [[ $return_code -ne 0 ]]; then
		OSL_RSRC_end_managed_write_operation_with_error "$rsrc_dir" "$rsrc_id"
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
	fi
	OSL_RSRC_state=$OSlmomd_bkp

	if [[ $? -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "error while making component \"$component_version\" src available !"
	fi
	
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


	local OSlmomd_bkp=$OSL_RSRC_state
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
			
			## cleanup possible existing bad dir
			local dest_dir=$(CVM_COMPONENT_get_component_shared_src_dir $component_version)
			rm -rf "$dest_dir"
			
			OSL_ARCHIVE_unpack_to "$(CVM_COMPONENT_get_component_shared_archive_path $component_version)" "$dest_dir" "$unexpected_archive_unpack_dir"
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
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
	fi
	OSL_RSRC_state=$OSlmomd_bkp

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

	local OSlmomd_bkp=$OSL_RSRC_state
	OSL_RSRC_begin_managed_write_operation "$rsrc_dir" "$rsrc_id"
	
	## how do we get the archive ??
	CVM_COMP_INSTALL_get_value_from_cached_component_for "archive_obtention_mode"
	return_code=1 # error/not exist by default
	case $return_value in
	### from the web
	"download")
		CVM_COMP_INSTALL_get_value_from_cached_component_for "archive_download_url"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Can't read URL of given component archive..."
		else
			local archive_url=$return_value
			local download_dir="$CVM_ARCHIVES_DIR/$component_version"
			mkdir -p "$download_dir"
			local prev_wd=$(pwd)
			cd "$download_dir"
			CVM_COMP_INSTALL_get_value_from_cached_component_for "archive_download_target"
			if [[ $? -ne 0 ]]; then
				## direct download
				wget "$archive_url"
			else
				## download to an explicitely specified file
				wget "$archive_url" --output-document="$return_value"
			fi
			return_code=$?
			## immediate error msg for clarity
			if [[ $return_code -ne 0 ]]; then
				OSL_OUTPUT_display_error_message "Download failed from : $archive_url"
			fi
			
			## back to prev dir
			cd "$prev_wd"
		fi
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
	else
		OSL_RSRC_end_managed_write_operation "$rsrc_dir" "$rsrc_id"
		if [[ $? -ne 0 ]]; then
			OSL_OUTPUT_display_error_message "Concurrent access to resource : $rsrc_id"
			return_code=1 # error
		fi
	fi
	OSL_RSRC_state=$OSlmomd_bkp

	if [[ $return_code -ne 0 ]]; then
		OSL_OUTPUT_display_error_message "couldn't obtain component \"$component_version\" archive..."
	else
		CVM_debug "* component \"$component_version\" shared archive obtained successfully."
	fi

	return $return_code
}


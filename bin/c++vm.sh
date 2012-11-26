#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm


## We use the OSL shell lib
OSL_debug=true
source osl_lib_init.sh
source osl_lib_debug.sh
source osl_lib_output.sh
source osl_lib_string.sh
source osl_lib_rsrc.sh
source osl_lib_version.sh
source osl_lib_exit.sh
source osl_lib_capabilities.sh
source osl_lib_archive.sh
source osl_lib_pathvar.sh

## Now load our config
source c++vm_inc_env.sh

## And load our primitives
source c++vm_lib_base.sh
source c++vm_lib_compset.sh
source c++vm_lib_compfile.sh
source c++vm_lib_component.sh
source c++vm_lib_comp_selection.sh
source c++vm_lib_comp_installation.sh
source c++vm_lib_commands.sh


echo ""

usage()
{
	echo ""
	echo " C++ Version Manager"
	echo ""
	echo "Usage : c++vm <command> ..."
	echo "Commands :"
	echo "  help"
	echo "  status"
	echo "  list"
	echo "  new <name>"
	echo "  use [name]"
	echo "  update"
	echo "  set_compfile [compfile]"
	echo "..."
	exit 1
}


## read params
RAW_CMD=$1
PARAM2=$2
PARAM3=$3

## init and defaults
CVM_verbose=true  ## dev actively in progress
CVM_COMPSET_ensure_default_compset

## process params and env
CMD=$(OSL_STRING_to_lower $RAW_CMD)
CURRENT_COMPSET=$(CVM_COMPSET_get_current_active_compset)


ensure_param2()
{
	if [[ -z "$PARAM2" ]]; then
		## no param2.
		## It was expected.
		OSL_OUTPUT_display_error_message "XXX a second param was expected."
		usage # REM : will exit
	fi
}

ensure_param2_as_compset()
{
	ensure_param2
	
	local raw_compset_name=$PARAM2
	
	## clean the given name
	local compset_name=`echo $raw_compset_name | awk '{print tolower($0)}'`
	
	## put it back into the param var
	PARAM_COMPSET=$compset_name
}


## processing
exec_cmd_status()
{
	CVM_COMMANDS_print_status
}
exec_cmd_list()
{
	CVM_COMMANDS_list_compsets
}
exec_cmd_create_new_compset()
{
	ensure_param2_as_compset
	echo "* creating component set \"$PARAM_COMPSET\"..."
	CVM_COMPSET_create_compset_if_needed $PARAM_COMPSET
}
exec_cmd_use_existing_compset()
{
	ensure_param2_as_compset
	echo "* making component set \"$PARAM_COMPSET\" default..."
	CVM_COMPSET_save_current_active_compset $PARAM_COMPSET
}
exec_cmd_update_current_compset()
{
	echo "* updating component set \"$CURRENT_COMPSET\"..."
	CVM_COMPFILE_update_compset $CURRENT_COMPSET
}
exec_cmd_upgrade_current_compset()
{
	echo "* upgrading component set \"$CURRENT_COMPSET\"..."
	CVM_COMP_INSTALL_upgrade_compset $CURRENT_COMPSET
}
exec_cmd_process_compfile_to_current_compset()
{
	## todo check params
	local compfile_path=$CVM_DEFAULT_COMPFILE_NAME
	echo "* Setting component file \"$compfile_path\" to component set \"$CURRENT_COMPSET\"..."
	CVM_COMPFILE_set  $compfile_path  $CURRENT_COMPSET
	
	exec_cmd_update_current_compset
}



## starts execution

CVM_debug "starting execution of command : \"$CMD\"..."
case $CMD in
"")
	echo "Welcome to C++ Version Manager !"
	echo "Please give a command, cf. help below :"
	usage # REM : will exit
	;;
### display help and exit
"help")
	usage # REM : will exit
	;;
### always helpful
"status")
	exec_cmd_status
	;;
### list avaliable component sets
"list")
	exec_cmd_list
	;;
### create a new component set
"new")
	exec_cmd_create_new_compset
	;;
### use a specific component set
"use")
	exec_cmd_use_existing_compset
	;;
### update=reparse current component set
"update")
	exec_cmd_update_current_compset
	;;
### upgrade=install current component set
"upgrade")
	exec_cmd_upgrade_current_compset
	;;
### install a new component set
"set_compfile")
	exec_cmd_process_compfile_to_current_compset
	;;
### ??? command not recognized
*)
	echo "XXX unrecognized command : $CMD..."
	usage # REM : will exit
	;;
esac

echo ""

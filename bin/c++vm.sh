#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm


## We use the OSL shell lib
source osl_lib_init.sh
source osl_lib_debug.sh

## Now load our config
source c++vm_inc_env.sh

## And load our primitives
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
	echo "  new"
	echo "  update"
	echo "..."
	exit 1
}


## read params
RAW_CMD=$1


## init defaults
CVM_verbose=true


## process params
CMD=`echo $RAW_CMD | awk '{print tolower($0)}'`
PARAM2=$2
PARAM3=$3

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
	echo "TODO..."
}
exec_cmd_create_new_compset()
{
	ensure_param2_as_compset
	echo "* creating compset $PARAM_COMPSET..."
	CVM_COMPSET_create_compset_if_needed $PARAM_COMPSET
}
exec_cmd_use_existing_compset()
{
	ensure_param2_as_compset
	echo "* making compset $PARAM_COMPSET default..."
	CVM_COMPSET_save_current_active_compset $PARAM_COMPSET
}
exec_cmd_update_existing_compset()
{
	ensure_param2_as_compset
	echo "* updating compset $PARAM_COMPSET..."
	CVM_COMPSET_update_compset $PARAM_COMPSET
}


## starts execution

CVM_COMPSET_ensure_default_compset

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
### use a specific component set
"update")
	exec_cmd_update_existing_compset
	;;
### ??? command not recognized
*)
	echo "XXX unrecognized command : $CMD..."
	usage # REM : will exit
	;;
esac

echo ""

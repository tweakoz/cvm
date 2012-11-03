#! /bin/bash

## C++ Version Manager
## by Offirmo
## Inspired from RVM : https://rvm.io//

## We use the OSL shell lib
source osl_lib_init.sh

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
	ensure_param2
	CVM_COMPSET_create_compset $PARAM2
}


## starts execution
CVM_debug "starting execution of command : \"$CMD\"..."
case $CMD in
"")
	echo "XXX You must give a command..."
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
### ??? command not recognized
*)
	echo "XXX unrecognized command : $CMD..."
	usage # REM : will exit
	;;
esac

echo ""

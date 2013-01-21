#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm


## We use the OSL shell lib
#OSL_debug=true
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


usage()
{
	echo ""
	echo " C++ Version Manager"
	echo ""
	echo "Usage : cvm_exec <command> ..."
	exit 1
}


## read params
CMD=$*

## init and defaults
CVM_verbose=false
CVM_COMPSET_ensure_default_compset

## process params and env
CURRENT_COMPSET=$(CVM_COMPSET_get_current_active_compset)

## prepare env
CVM_COMPSET_update_environment_vars_with_current_compset

## starts execution

CVM_debug "starting execution of command : \"$CMD\"..."
return_code=1
case $CMD in
"")
	echo "Welcome to C++ Version Manager !"
	echo "Please give a command, cf. help below :"
	usage # REM : will exit
	;;
### 
*)
	$CMD
	return_code=$?
	;;
esac

exit $return_code

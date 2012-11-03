#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_commands.sh

source c++vm_lib_compset.sh


CVM_COMMANDS_print_status()
{
	echo "++++   C++ Version Manager   ++++"
	echo "* version         : $CVM_VERSION"
	echo "* stamp           : $(stat -c %y "$OSL_INIT_script_full_path")"
	echo "* current compset : `cat \"$CVM_ACTIVE_COMPSET\"`"
	echo "* compset count   : [TODO]"
}


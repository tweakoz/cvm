#! /bin/bash

## C++ Version Manager
## by Offirmo
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_base.sh

source c++vm_inc_env.sh

source osl_lib_debug.sh
source osl_lib_output.sh


CVM_debug()
{
	$CVM_verbose && OSL_debug $*
}

#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_base.sh

## REM : required includes are in main file


CVM_debug()
{
	$CVM_verbose && OSL_debug "$*"
}

CVM_debug_multi()
{
	$CVM_verbose && OSL_debug_multi "$*"
}

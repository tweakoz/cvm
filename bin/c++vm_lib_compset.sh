#! /bin/bash

## C++ Version Manager
## by Offirmo
##
## This file defines :
##   basic utilities methods used in c++vm scripts
##
## This file is not meant to be executed, only sourced :
##   source c++vm_lib_compset.sh

source c++vm_lib_base.sh


CVM_COMPSET_create_compset()
{
	local raw_compset_name=$1
	
	# first clean the given name
	local compset_name=`echo $raw_compset_name | awk '{print tolower($0)}'`
	
	CVM_debug "creating compset \"$compset_name\"..."
	OSL_OUTPUT_abort_execution_because_not_implemented
}

CVM_COMPSET_ensure_compset()
{
	local raw_compset_name=$1
	
	# first clean the given name
	local compset_name=`echo $raw_compset_name | awk '{print tolower($0)}'`

	# then check if it exists
	
	CVM_debug "creating compset \"$compset_name\"..."
	OSL_OUTPUT_abort_execution_because_not_implemented
}

CVM_COMPSET_delete_compset()
{
	local raw_compset_name=$1
	
	# first clean the given name
	local compset_name=`echo $raw_compset_name | awk '{print tolower($0)}'`
	
	CVM_debug "creating compset \"$compset_name\"..."
	OSL_OUTPUT_abort_execution_because_not_implemented
}

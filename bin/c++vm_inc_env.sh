#! /bin/bash

## C++ Version Manager
## by Offirmo, https://github.com/Offirmo/cvm
## 
## This file define vars about current C++VM environment
## This file is meant to be sourced :
##   source c++vm_inc_env.sh


## current version
CVM_VERSION="1.0.1"
CVM_STAMP="2012/12/16"


## Various constants
CVM_DEFAULT_COMPFILE_NAME="compfile"
CVM_DEFAULT_ENV_FILE_NAME="environment"

CVM_ROOT_COMPONENT_NAME="app"
CVM_INSTALL_DIR="$OSL_INIT_script_full_dir/.."

CVM_COMP_SELECTION_DIR_NAME="components_selection"
CVM_COMP_INSTALL_BUILD_DIR_NAME="build"
CVM_COMP_INSTALL_FINAL_DIR_NAME="result"
CVM_COMP_INCLUDES_FOR_INDEXER_DIR_NAME="$CVM_COMP_INSTALL_FINAL_DIR_NAME/includes_for_indexer"

CVM_COMP_RSRC_ID_PART="component"
CVM_COMP_APT_PKT_RSRC_ID_PART="apt_pkt"
CVM_COMP_OBJS_RSRC_ID_PART="built_objects"
CVM_COMP_INSTALLED_OBJS_RSRC_ID_PART="installed_objects"
CVM_COMP_SRC_RSRC_ID_PART="src"
CVM_COMP_ARCHIVE_RSRC_ID_PART="archive"


## a dir where we'll put our stuff
CVM_DEFAULT_DATA_DIR=$HOME/.cvm
CVM_DATA_DIR=$CVM_DEFAULT_DATA_DIR
OSL_INIT_ensure_dir $CVM_DATA_DIR

## A config file where user will be able to change stuff
CVM_CONFIG_PATH="$CVM_DATA_DIR/config"
## create it if needed
if [[ -f "$CVM_CONFIG_PATH" ]]; then
	## exists, nothing to do
	do_nothing=1
else
	## create the file from a model if possible
	touch "$CVM_CONFIG_PATH"
	config_template="$CVM_INSTALL_DIR/misc/config.example"
	#echo "testing $config_template..."
	if [[ -f "$config_template" ]]; then
		## example file is available
		cp "$config_template" "$CVM_CONFIG_PATH"
	else
		## build a minimal config file
		echo "#! /bin/bash " >> "$CVM_CONFIG_PATH"
		echo "" >> "$CVM_CONFIG_PATH"
		echo "## C++ VM config file" >> "$CVM_CONFIG_PATH"
	fi
fi

## now load the config
## include guard : really useful ?
if [[ -z "$CVM_CONFIG_SOURCED" ]]; then
	OSL_debug "sourcing $CVM_CONFIG_PATH..."
	source "$CVM_CONFIG_PATH"
	CVM_CONFIG_SOURCED=true
fi

## data dir may have changed
OSL_INIT_ensure_dir $CVM_DATA_DIR
## early exit in case of failure :
if [[ ! -d "$CVM_DATA_DIR" ]]; then
	echo "XXX no write rights to create data dir : $CVM_DATA_DIR"
	echo "XXX can't continue"
	echo ""
	exit 1
fi

## a dir where we'll do unclean stuff
## like uncompressing
if [[ -z "$CVM_TEMP_DIR" ]]; then
	CVM_TEMP_DIR=$CVM_DATA_DIR/temp
fi
OSL_INIT_ensure_dir $CVM_TEMP_DIR

## a dir where we'll cache stuff.
## Stuff in this dir can be redownloaded / regenerated
## and is safe to delete.
if [[ -z "$CVM_CACHE_DIR" ]]; then
	CVM_CACHE_DIR=$CVM_DATA_DIR/cache
fi
OSL_INIT_ensure_dir $CVM_CACHE_DIR

## in this cache, some stuff will be shared between component sets
## and some other stuff will not
CVM_SHARED_CACHE_DIR=$CVM_CACHE_DIR/shared
OSL_INIT_ensure_dir $CVM_SHARED_CACHE_DIR

## a dir for downloaded components definitions
CVM_COMP_DEFS_DIR=$CVM_SHARED_CACHE_DIR/components
OSL_INIT_ensure_dir $CVM_COMP_DEFS_DIR

## a dir for downloaded archives, obviously shareable
CVM_ARCHIVES_DIR=$CVM_SHARED_CACHE_DIR/archives
OSL_INIT_ensure_dir $CVM_ARCHIVES_DIR

## a dir for downloaded src, obviously shareable
## as long as they remain pristine (i.e. no "configure" etc.)
CVM_SRC_DIR=$CVM_SHARED_CACHE_DIR/src
OSL_INIT_ensure_dir $CVM_SRC_DIR


## the dir for integrated components definitions
CVM_INTEGRATED_COMP_DEFS_DIR=$CVM_INSTALL_DIR/components


## a dir for component sets
CVM_COMPSETS_DIR=$CVM_DATA_DIR/compsets
OSL_INIT_ensure_dir $CVM_COMPSETS_DIR

## a file storing currently active compset
CVM_ACTIVE_COMPSET=$CVM_COMPSETS_DIR/active_compset

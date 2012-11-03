#! /bin/bash

## C++ Version Manager
## by Offirmo

## This file define vars about current C++VM environment
## This file is not meant to be sourced :
##   source c++vm_inc_env.sh



## current version
CVM_VERSION="0.1"

## a dir where we'll put our stuff
CVM_DATA_DIR=$HOME/.c++vm
OSL_INIT_ensure_dir $CVM_DATA_DIR

## a dir where we'll cache stuff.
## Stuff in this dir can be redownloaded / regenerated
## and is safe to delete.
CVM_CACHE_DIR=$CVM_DATA_DIR/cache
OSL_INIT_ensure_dir $CVM_CACHE_DIR

## in this cache, some stuff will be shared between component sets
## and some other stuff will not
CVM_SHARED_CACHE_DIR=$CVM_CACHE_DIR/shared
OSL_INIT_ensure_dir $CVM_SHARED_CACHE_DIR

## a dir for components definitions
CVM_COMP_DEFS_DIR=$CVM_SHARED_CACHE_DIR/components
OSL_INIT_ensure_dir $CVM_COMP_DEFS_DIR

## a dir for downloaded archives, obviously shareable
CVM_ARCHIVES_DIR=$CVM_SHARED_CACHE_DIR/archives
OSL_INIT_ensure_dir $CVM_ARCHIVES_DIR

## a dir for downloaded src, obviously shareable
## as long as they remain pristine (i.e. no "configure" etc.)
CVM_SRC_DIR=$CVM_SHARED_CACHE_DIR/src
OSL_INIT_ensure_dir $CVM_SRC_DIR

## a dir for component sets
CVM_COMPSETS_DIR=$CVM_DATA_DIR/compsets
OSL_INIT_ensure_dir $CVM_COMPSETS_DIR


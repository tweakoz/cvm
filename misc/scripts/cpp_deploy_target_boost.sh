#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !

## This script contains information about the boost lib
## and how to make it available on a system

#echo "Hello from boost !"

TARGET_BUILD_TYPE='boost'
TARGET_REQUIREMENTS=""

TARGET_LATEST_SRC="svn"
TARGET_GIT_REPO=""

## still not sure about that. bjam is cryptic. Better be safe.
TARGET_OOSBUILD_AVAILABLE=false

## version specific vars
TARGET_SRC_ARCHIVE_1_51="boost_1_51_0.tar.bz2"

function cpp_env_target_hook_prepare_build
{
	# nothing for now
}

function cpp_env_target_hook_build
{
	## boost is in-source build (I think) so we move into the copy of source
	ensure_exec cd $TARGET_SRC_DIR
	echo "* configuring..."
	ensure_exec ./bootstrap.sh --with-libraries=all --prefix=$PREFIX
	echo "* building..."
	# the --layout option is very important for Wt cmake to find the correct boost libs
	# hat tip : http://stackoverflow.com/a/6354570/587407
	ensure_exec ./b2 install --layout=tagged --without-mpi --prefix=$PREFIX --build-dir=$CPP_BUILDS_DIR
}

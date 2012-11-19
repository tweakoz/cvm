#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !

## This script contains information about the boost lib
## and how to make it available on a system

echo "Hello from wt !"

TARGET_BUILD_TYPE='cmake'
TARGET_REQUIREMENTS="boost"

TARGET_LATEST_SRC="git"
TARGET_GIT_REPO=git://github.com/kdeforche/wt.git

## enjoy cmake power !
TARGET_OOSBUILD_AVAILABLE=true

## version specific vars
TARGET_SRC_ARCHIVE_20120915="wt_20120915.zip"

function cpp_env_target_hook_prepare_build
{
	export BOOST_ROOT=$CPP_LIBS_DIR/boost
	export BOOST_INCLUDEDIR=$BOOST_ROOT/include
	export BOOST_LIBRARYDIR=$BOOST_ROOT/lib
	echo "* preparing prerequisites..."
	echo "BOOST_ROOT       : $BOOST_ROOT"
	echo "BOOST_INCLUDEDIR : $BOOST_INCLUDEDIR"
	echo "BOOST_LIBRARYDIR : $BOOST_LIBRARYDIR"
}

function cpp_env_target_hook_build
{
	# nothing for now
}

#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !


# Common params parsing and interpretation
# for other cpp_deploy scripts
# NOTE : this script is sourced from other scripts,
#        it is not meant to be executed
# Offirmo 2012/10
#
# source cpp_deploy_parse_params_and_init.sh

CPP_ENV_NAME=$1
CPP_ENV_NAME=gccdefault
TARGET_NAME=$2
TARGET_NAME='boost'
TARGET_NAME='wt'
TARGET_NAME='cmake'
TARGET_VERSION=$3
TARGET_VERSION='1.51'
#TARGET_VERSION='latest'
TARGET_VERSION='20120915'
TARGET_VERSION='2.8.9'
echo "* CPP_ENV_NAME       : $CPP_ENV_NAME"
echo "* TARGET_NAME        : $TARGET_NAME"
echo "* TARGET_VERSION     : $TARGET_VERSION"

if [[ "$CPP_ENV_NAME" == "" ]]; then
	echo "error : can't read the env."
	exit 1
fi
if [[ "$TARGET_NAME" == "" ]]; then
	echo "error : can't read the target."
	exit 1
fi
if [[ "$TARGET_VERSION" == "" ]]; then
	echo "error : can't read the required version."
	exit 1
fi

## source some config files
## generic
source $MYDIR/cpp_deploy_env.sh
## specific to current env
source $CPP_DIR/${CPP_ENV_NAME}/${CPP_ENV_DEF_FILE}
## specific to current target
#echo "sourcing $MYDIR/${CPP_TARGET_DEF_FILE_RADIX}${TARGET_NAME}.sh..."
source $MYDIR/${CPP_TARGET_DEF_FILE_RADIX}${TARGET_NAME}.sh

# for internal handling, we need a version usable in a shell variable name
FORMATTED_TARGET_VERSION=`echo "$TARGET_VERSION" | sed "s/\./_/g"`
echo "* FORMATTED_TARGET_VERSION : $FORMATTED_TARGET_VERSION"

# now build other variables
TARGET_BASE_DIR=${TARGET_NAME}_${FORMATTED_TARGET_VERSION}
TARGET_SHARED_SRC_DIR=$CPP_SHARED_SRC_DIR/$TARGET_BASE_DIR
if [[ $TARGET_OOSBUILD_AVAILABLE != true ]]; then
	## need a copy of source, since this project only allows in-source build...
	TARGET_SRC_DIR=$CPP_ISBSRC_DIR/$TARGET_BASE_DIR
else
	# the best
	TARGET_SRC_DIR=$TARGET_SHARED_SRC_DIR
fi

#SHARED_SRC_DIR=$CPP_SHARED_SRC_DIR/$TARGET_SRC_BASE_DIR

TARGET_BUILD_DIR=$CPP_BUILDS_DIR/$TARGET_BASE_DIR

echo "* CPP_ISBSRC_DIR     : $CPP_ISBSRC_DIR"
echo "* CPP_BUILDS_DIR     : $CPP_BUILDS_DIR"
echo "* CPP_LIBS_DIR       : $CPP_LIBS_DIR"
echo "* CPP_BINS_DIR       : $CPP_BINS_DIR"
echo "* TARGET_BASE_DIR    : $TARGET_BASE_DIR"
echo "* TARGET_SHARED_SRC_DIR : $TARGET_SHARED_SRC_DIR"
echo "* TARGET_SRC_DIR     : $TARGET_SRC_DIR"
echo "* TARGET_BUILD_DIR   : $TARGET_BUILD_DIR"



### a little util
function ensure_exec
{
	typeset var cmd=$*
	echo "executing : $cmd"
	$cmd
	typeset var ret=$?
	if [[ $ret -ne 0 ]]; then
		echo "XXX error executing $*"
		echo "XXX return = $ret"
		exit 1
	else
		#echo "exec ok."
		do_nothing=1
	fi
}


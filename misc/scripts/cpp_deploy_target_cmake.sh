#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !

## This script contains information about the boost lib
## and how to make it available on a system

echo "Hello from cmake !"

TARGET_BUILD_TYPE='cmake-bootstrap'
TARGET_REQUIREMENTS=''

TARGET_LATEST_SRC='?'
TARGET_GIT_REPO='?'

## enjoy cmake power !
TARGET_OOSBUILD_AVAILABLE='?'

## version specific vars
TARGET_SRC_ARCHIVE_2_8_9="cmake-2.8.9.tar.gz"
TARGET_SRC_EXPECTED_UNPACK_DIR_2_8_9="cmake-2.8.9"

function cpp_env_target_hook_prepare_build
{
	# nothing for now
}

function cpp_env_target_hook_build
{
	# nothing for now
}

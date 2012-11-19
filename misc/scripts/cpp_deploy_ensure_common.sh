#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !


# sub-script, do not maunch directly



function cpp_deploy_validate_src
{
	if [[ -d "$TARGET_SRC_DIR" ]]; then
		## OK
		do_nothing=1
	else
		## src not available ???
		echo "XXX expected src dir not found : $TARGET_SRC_DIR !"
		exit 1
	fi
}


function cpp_deploy_ensure_build
{
	local dest_dir=$1
	echo "* building..."
	local PREFIX=$dest_dir/$TARGET_NAME
	echo "* prefix  : $PREFIX"
	echo "* testing $PREFIX..."
	if [[ -d $PREFIX ]]; then
		echo "  --> already present"
	else
		echo "  --> needs build"
		ensure_exec mkdir -p $CPP_BUILDS_DIR
		case $TARGET_BUILD_TYPE in
		cmake)
			ensure_exec mkdir -p $TARGET_BUILD_DIR
			ensure_exec cd $TARGET_BUILD_DIR
			ensure_exec pwd
			echo "XXX requirements"
			cpp_env_target_hook_prepare_build
			echo "* configuring..."
			ensure_exec cmake -Wdev $TARGET_SRC_DIR -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX
			exit 1
			ensure_exec make
			;;
		*)
			# known : boost, cmake-bootstrap
			echo "* Note : unknown target build type : \"$TARGET_BUILD_TYPE\" : using hook "
			cpp_env_target_hook_build
			;;
		esac
	fi
}


function cpp_deploy_ensure_lib
{
	cpp_deploy_validate_src
	cpp_deploy_ensure_build  $CPP_LIBS_DIR
}

function cpp_deploy_ensure_app
{
	cpp_deploy_validate_src
	cpp_deploy_ensure_build  $CPP_BINS_DIR
}

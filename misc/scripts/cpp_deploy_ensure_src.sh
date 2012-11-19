#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !


# Ensure presence of the sources of a lib in the given dir
# For use with a deployment tool like puppet.
# Offirmo 2012/10

#  cpp_deploy_ensure_source.sh gccdefault wt latest
#  cpp_deploy_ensure_source.sh gccdefault wt latest




echo ""
echo "*** Automatic C++ lib deployment ***"
echo "***        --> ensure src        ***"
echo ""

echo "* params             : \"$*\""

MYSELF=`readlink -f -n $0`
MYDIR=`dirname "$MYSELF"`
echo "* this script is     : $MYSELF"
echo "* script parent dir  : $MYDIR"


# common code
source $MYDIR/cpp_deploy_parse_params_and_init.sh


function cpp_deploy_ensure_latest_shared_src
{
	case $TARGET_LATEST_SRC in
	git)
		if [[ -d $TARGET_SHARED_SRC_DIR/.git ]]; then
			## repo already exists
			## update it
			cd $TARGET_SHARED_SRC_DIR
			result=`git pull`
			## Now up-to-date.
			echo $result
			## XXX TODO check result
		else
			## repo doesn't exist yet
			## create it
			git clone  $TARGET_GIT_REPO  $TARGET_SHARED_SRC_DIR
	#Initialized empty Git repository in /srv/dev/cpp/shared/src/wt_latest/.git/
	#remote: Counting objects: 19314, done.
	#remote: Compressing objects: 100% (3660/3660), done.
	#remote: Total 19314 (delta 15835), reused 19036 (delta 15568)
	#Receiving objects: 100% (19314/19314), 11.34 MiB | 1.27 MiB/s, done.
	#Resolving deltas: 100% (15835/15835), done.
		fi
		;;
	*)
		echo "unknown latest src type !"
		;;
	esac
}


function cpp_deploy_ensure_specific_shared_src
{
	## first build the expected name of the archive
	## we need indirection
	## 1st build the name of the variable
	local temp="TARGET_SRC_ARCHIVE_$FORMATTED_TARGET_VERSION"
	#echo "reading value of $temp..."
	## now read the value of this constructed var
	eval temp=\$$temp
	## and eventually, build the full name
	local src_archive=$CPP_SHARED_ARCHIVES_DIR/$temp
	## same with expected unpack dir
	temp="TARGET_SRC_EXPECTED_UNPACK_DIR_$FORMATTED_TARGET_VERSION"
	#echo "reading value of $temp..."
	eval temp=\$$temp
	local expected_unpack_dir=$temp
	echo "* expected src archive for $TARGET_VERSION : $src_archive"
	if [[ -f $src_archive ]]; then
		# fine, file exists, we may proceed.
		do_nothing=1
	else
		# file is missing, can't proceed !
		echo "XXX src for $TARGET_VERSION, expected in $src_archive, was not found..."
		exit 1
	fi
	unpack_archive  "$src_archive"  "$TARGET_SHARED_SRC_DIR"  "$expected_unpack_dir"
	return $?
}


function cpp_deploy_ensure_src
{
	#mkdir -p `basename $SRC_DIR`
	if [[ $TARGET_VERSION == latest ]]; then
		cpp_deploy_ensure_latest_shared_src
	else
		cpp_deploy_ensure_specific_shared_src
	fi
	if [[ "$TARGET_SRC_DIR" != "$TARGET_SHARED_SRC_DIR" ]]; then
		echo "* duplicating source for in-source build..."
		if [[ -d "$TARGET_SRC_DIR" ]]; then
			## already done
			echo "  --> already done."
		else
			cp -r $TARGET_SHARED_SRC_DIR $TARGET_SRC_DIR
		fi
	fi
}


## let's execute
cpp_deploy_ensure_src

echo "~~~ Everything looks fine. Asked src are now available. ~~~"

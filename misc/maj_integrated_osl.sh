#!/bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file updates the embedded OSL copy.

echo ""

script_full_path=`readlink -f "$1"`
#echo "script_full_path set to $script_full_path"
script_full_dir=`dirname "$script_full_path"`

## detect an existing OSL
installed_osl_version_script_path=`which 'osl_version.sh' 2> /dev/null`
if [[ $? -ne 0 ]]; then
	echo "XXX failed to detect system OSL !!!"
else
	## an OSL is in the path
	echo "installed OSL found ! ($installed_osl_version_script_path)"

	## first rationalize the path
	installed_osl_version_script_path=`readlink -f "$installed_osl_version_script_path"`
	## refine path
	installed_osl_copy_bin_path=`dirname "$installed_osl_version_script_path"`
	echo "OSL copy found in : $installed_osl_copy_bin_path"

	## copy it
	echo "copying from $installed_osl_copy_bin_path to $script_full_dir/contrib/offirmo-shell-lib/bin"
	cp -r "$installed_osl_copy_bin_path"/* "$script_full_dir/contrib/offirmo-shell-lib/bin"
fi

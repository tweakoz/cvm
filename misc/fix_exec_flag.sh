#!/bin/sh -x

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file just fix the exec flag for cvm scripts.

set -ev

script_full_path=`readlink -f "$0"`
echo "script_full_path : $script_full_path"
script_full_dir=`dirname "$script_full_path"`
echo "script_full_dir  : $script_full_dir"
cvm_full_dir=`dirname "$script_full_dir"`
echo "cvm_full_dir     : to $cvm_full_dir"

## supposedly run from OSL root dir

chmod +x "$cvm_full_dir/bin/cvm"
chmod +x "$cvm_full_dir/bin/cvm_exec"
chmod +x "$cvm_full_dir/bin/cvm.sh"
chmod +x "$cvm_full_dir/bin/cvm_exec.sh"

chmod +x "$cvm_full_dir/components/tool.cmake/custom_build.2.8.10.sh"

embedded_osl_path="$cvm_full_dir/misc/contrib/offirmo-shell-lib/bin"
chmod +x "$embedded_osl_path/osl_help.sh"
chmod +x "$embedded_osl_path/osl_version.sh"

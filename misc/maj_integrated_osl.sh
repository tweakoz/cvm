#!/bin/sh -x

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file just fix the exec flag for cvm scripts.
## Just don't care about it.

set -ev

## supposedly run from OSL root dir

chmod +x bin/cvm
chmod +x bin/c++vm
chmod +x bin/cvm_exec
chmod +x bin/c++vm.sh
chmod +x bin/c++vm_exec.sh
chmod +x components/tool.cmake/custom_build.2.8.10.sh

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
echo "***        --> ensure lib        ***"
echo ""

echo "* params             : \"$*\""

MYSELF=`readlink -f -n $0`
MYDIR=`dirname "$MYSELF"`
echo "* this script is      : $MYSELF"
echo "* script parent dir   : $MYDIR"


# common code
source $MYDIR/cpp_deploy_parse_params_and_init.sh
source $MYDIR/cpp_deploy_ensure_common.sh

cpp_deploy_ensure_lib

echo "~~~ Everything looks fine. Asked lib is now available. ~~~"

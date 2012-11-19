#! /bin/bash

### XXX This file is automatically installed via puppet ! 
###     Be sure to alter the original, not the copy !


# Ensure presence of a built app.
# For use with a deployment tool like puppet.
# Offirmo 2012/10


echo ""
echo "*** Automatic C++ lib deployment ***"
echo "***        --> ensure app        ***"
echo ""

echo "* params             : \"$*\""

MYSELF=`readlink -f -n $0`
MYDIR=`dirname "$MYSELF"`
echo "* this script is      : $MYSELF"
echo "* script parent dir   : $MYDIR"


# common code
source $MYDIR/cpp_deploy_parse_params_and_init.sh
source $MYDIR/cpp_deploy_ensure_common.sh

cpp_deploy_ensure_app

echo "~~~ Everything looks fine. Asked app is now available. ~~~"

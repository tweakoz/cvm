#! /bin/bash

## C++ Version Manager
## by Offirmo
## Inspired from RVM : https://rvm.io//

echo ""

usage()
{
	echo ""
	echo " C++ Version Manager"
	echo ""
	echo "Usage : c++vm <command> ..."
	echo "Commands :"
	echo "  help"
	echo "[TODO]"
	exit 1
}


## read params
CMD=$1


## process params
case $CMD in
"")
	echo "XXX You must give a command..."
	usage # REM : will exit
	;;
*)
	echo "XXX unrecognized command : $CMD..."
	usage # REM : will exit
	;;
esac

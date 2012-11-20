#! /bin/bash

PREFIX=$1
OPTIONS=$2

echo "hello from custom build script !"
echo "PREFIX=$PREFIX"
echo "OPTIONS=$OPTIONS"
echo "cwd=$(pwd)"

./bootstrap --prefix="$PREFIX"
make
make install

exit $?

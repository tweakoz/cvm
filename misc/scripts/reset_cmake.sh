#! /bin/bash --debug

echo ""
echo "*** reset cmake ***"

TOOL_DIR=/srv/dev/tools/
ARCHIVE=$TOOL_DIR/shared/downloads/cmake-2.8.9.tar.gz
SRC_DIR=$TOOL_DIR/shared/src/cmake-2.8.9
BUILD_DIR=cmake_build
PREFIX=$TOOL_DIR/gcc44/cmake

echo "- cleaning up..."
#rm -rf $SRC_DIR
rm -rf $BUILD_DIR
rm -rf $PREFIX

echo "- preparing..."
if [[ ! -d $SRC_DIR ]]; then
	mkdir -p $SRC_DIR
	tar xzfv $ARCHIVE -C `dirname $SRC_DIR`
fi
mkdir $BUILD_DIR

echo "- configuring..."
BUILD_MODE=bootstrap
if [[ $BUILD_MODE == "bootstrap" ]]; then
	cd $SRC_DIR
	./bootstrap --prefix=$PREFIX
else
	cd $BUILD_DIR
	cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX $SRC_DIR 
fi

make
make install

echo "Cmake done."
notify_current_user "cmake compilation done"

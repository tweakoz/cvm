#! /bin/sh

echo ""
echo "*** reset Wt ***"

TOOL_DIR=/srv/dev/tools/
GIT_REPO=git://github.com/kdeforche/wt.git
SRC_DIR=$TOOL_DIR/shared/src/wt_latest
BUILD_DIR=wt_build
PREFIX=/srv/dev/tools/gcc44/wt


echo "- Cleaning up..."
#rm -rf $SRC_DIR
#rm -rf $BUILD_DIR


echo "- Preparing..."
#git clone $GIT_REPO $SRC_DIR
mkdir -p $BUILD_DIR

echo "- Configuring..."
cd $BUILD_DIR
export BOOST_ROOT=/srv/dev/tools/gcc44/boost
export BOOST_INCLUDEDIR=$BOOST_ROOT/include
export BOOST_LIBRARYDIR=$BOOST_ROOT/lib
cmake -Wdev $SRC_DIR -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX

echo "- Compiling..."
make

echo "- Installing..."
rm -rf $PREFIX
make install

echo "- Cleaning..."
#rm -rf $BUILD_DIR

echo "Wt done."
notify_current_user "Wt reinstallation finished."

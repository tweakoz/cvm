#! /bin/bash --debug

echo ""
echo "*** reset boost ***"

TOOL_DIR=/srv/dev/tools/
ARCHIVE=$TOOL_DIR/shared/downloads/boost_1_51_0.tar.bz2
SRC_DIR=$TOOL_DIR/shared/src/boost_1_51_0
BUILD_DIR=$TOOL_DIR/build44/boost_build
PREFIX=$TOOL_DIR/gcc44/boost

echo "- cleaning up..."
#rm -rf $BOOST_DIR
#rm -rf $BOOST_BUILD_DIR

echo "- preparing..."
if [[ ! -d $SRC_DIR ]]; then
	mkdir -p $SRC_DIR
	tar --bzip2 -xf $ARCHIVE -C `dirname $SRC_DIR`
fi

echo "- configuring..."
cd $SRC_DIR
#./bootstrap.sh --help
./bootstrap.sh --with-libraries=all --prefix=$PREFIX

echo "- compiling..."
rm -rf $PREFIX
mkdir -p $BUILD_DIR
# the --layout option is very important for Wt cmake to find the correct boost libs
# hat tip : http://stackoverflow.com/a/6354570/587407
./b2 install --layout=tagged --prefix=$PREFIX --build-dir=$BUILD_DIR

echo "Boost done."
notify_current_user "boost compilation done"

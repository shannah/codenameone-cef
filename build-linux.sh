#!/bin/sh
set -e
arch="64"
if [ "$arch" != "64" ]; then
	echo "Usage: sh build-linux.sh ARCH"
	echo " ARCH = 32 or 64"
	exit 1
fi

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
if [ ! -d java-cef ]; then
	mkdir java-cef
fi
cd java-cef
if [ ! -d src ]; then
	git clone https://github.com/shannah/java-cef src
fi
cd src
git pull origin master
if [ "$1" == "clean" ]; then
	rm -rf jcef_build
fi
if [ ! -d jcef_build ]; then
	mkdir jcef_build
fi

if [ "$arch" = "32" ]; then
	PROJECT_ARCH="x86"
fi
if [ "$arch" = "64" ]; then
	PROJECT_ARCH="x86_64"
fi

#https://drive.google.com/file/d/1pX6F_FEWe3Lm577fZDVoN6fKmE3Lskn5/view?usp=sharing

export CEF_VERSION=cef_binary_84.4.1+gfdc7504+chromium-84.0.4147.105

cd third_party/cef
FILENAME=${CEF_VERSION}_linux64
FILEID=1pX6F_FEWe3Lm577fZDVoN6fKmE3Lskn5
if [[ ! -d "$FILENAME" ]]; then
	if [[ ! -f "$FILENAME.zip" ]]; then
		sh $SCRIPTPATH/gdrive-download.sh "$FILEID" "$FILENAME.zip"
	fi
	unzip "$FILENAME.zip"
fi

cd ../..
cd jcef_build

cmake -G "Unix Makefiles" -DPROJECT_ARCH="$PROJECT_ARCH" -DCMAKE_BUILD_TYPE=Release ..
make -j4

cd ../tools
./compile.sh linux$arch
./make_distrib.sh linux$arch
strip ../binary_distrib/linux$arch/bin/lib/linux$arch/*.so

if [ -d $SCRIPTPATH/build ]; then
	rm -rf $SCRIPTPATH/build
fi
mkdir $SCRIPTPATH/build
TMPCEF=$SCRIPTPATH/build/cef
if [ -d $TMPCEF ]; then
	rm -rf $TMPCEF
fi

CEFROOT=$TMPCEF
cp -r ../binary_distrib/linux$arch/bin $CEFROOT
cd $SCRIPTPATH/build

jar -cvf cef-linux$arch.zip -C cef/ .

if [ ! -d $SCRIPTPATH/dist ]; then
	mkdir $SCRIPTPATH/dist
fi
mv cef-linux$arch.zip $SCRIPTPATH/dist/


#!/bin/sh
set -e
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
cd jcef_build

cmake -G "Visual Studio 14 Win64" ..
cd native
/c/Program\ Files\ \(x86\)/MSBuild/14.0/Bin/MSBuild.exe jcef.vcxproj -property:Configuration=Release
cd ../../tools
./compile.bat win64
./make_distrib.bat win64

if [ -d $SCRIPTPATH/build ]; then
	rm -rf $SCRIPTPATH/build
fi
mkdir $SCRIPTPATH/build
TMPCEF=$SCRIPTPATH/build/cef
if [ -d $TMPCEF ]; then
	rm -rf $TMPCEF
fi

CEFROOT=$TMPCEF
cp -r ../binary_distrib/win64/bin $CEFROOT
cd $SCRIPTPATH/build

jar -cvf cef-win64.zip -C cef/ .

if [ ! -d $SCRIPTPATH/dist ]; then
	mkdir $SCRIPTPATH/dist
fi
mv cef-win64.zip $SCRIPTPATH/dist/


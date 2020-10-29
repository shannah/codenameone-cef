#!/bin/sh
set -e
if [ -z "$JAVA_HOME_X86" ]; then
    JAVA_HOME_X86="/c/Program Files (x86)/AdoptOpenJDK/jdk8u262-b10"
fi
export JAVA_HOME="$JAVA_HOME_X86"
export PATH="$JAVA_HOME"/bin:$PATH
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

cmake -G "Visual Studio 14" ..
cd native
/c/Program\ Files\ \(x86\)/MSBuild/14.0/Bin/MSBuild.exe jcef.vcxproj -property:Configuration=Release
cd ../../tools
./compile.bat win32
./make_distrib.bat win32

if [ -d $SCRIPTPATH/build ]; then
	rm -rf $SCRIPTPATH/build
fi
mkdir $SCRIPTPATH/build
TMPCEF=$SCRIPTPATH/build/cef
if [ -d $TMPCEF ]; then
	rm -rf $TMPCEF
fi

CEFROOT=$TMPCEF
cp -r ../binary_distrib/win32/bin $CEFROOT
cd $SCRIPTPATH/build

jar -cvf cef-win32.zip -C cef/ .

if [ ! -d $SCRIPTPATH/dist ]; then
	mkdir $SCRIPTPATH/dist
fi
mv cef-win32.zip $SCRIPTPATH/dist/


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

export CEF_VERSION=cef_binary_84.4.1+gfdc7504+chromium-84.0.4147.105

cd third_party/cef
FILENAME=${CEF_VERSION}_windows64
#https://drive.google.com/file/d/1Opv_hBk2N5mc3KHGkAj4twZApeY85A7s/view?usp=sharing
FILEID=1Opv_hBk2N5mc3KHGkAj4twZApeY85A7s
if [[ ! -d "$FILENAME" ]]; then
	if [[ ! -f "$FILENAME.zip" ]]; then
	  echo "Downloading CEF binaries from gdrive..."
		sh $SCRIPTPATH/gdrive-download.sh "$FILEID" "$FILENAME.zip"
	fi
	unzip "$FILENAME.zip"
fi

cd ../..


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


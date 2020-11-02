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
cd third_party/cef
FILENAME=cef_binary_84.4.1+gfdc7504+chromium-84.0.4147.105_macosx64
FILEID=1YWWJT6ng1T6LAc-zztmWs3bsUTNcjyLP
if [[ ! -d "$FILENAME" ]]; then
	if [[ ! -f "$FILENAME.zip" ]]; then
		sh $SCRIPTPATH/gdrive-download.sh "$FILEID" "$FILENAME.zip"
	fi
	unzip "$FILENAME.zip"
fi

cd ../..
cd jcef_build

cmake -G "Xcode" -DPROJECT_ARCH="x86_64" ..
xcodebuild -project jcef.xcodeproj -configuration Release
cd native/Release
if [ -d $SCRIPTPATH/build ]; then
	rm -rf $SCRIPTPATH/build
fi
mkdir $SCRIPTPATH/build
TMPCEF=$SCRIPTPATH/build/cef
if [ -d $TMPCEF ]; then
	rm -rf $TMPCEF
fi
mkdir $TMPCEF
CEFROOT=$TMPCEF
if [ ! -d $CEFROOT/macos64 ]; then
	mkdir $CEFROOT/macos64; 
fi
cp -r "jcef_app.app/Contents/Frameworks/Chromium Embedded Framework.framework" $CEFROOT/macos64/
cp -r "jcef Helper.app" $CEFROOT/macos64/
cp -r "jcef Helper (GPU).app" $CEFROOT/macos64/
cp -r "jcef Helper (Plugin).app" $CEFROOT/macos64/
cp -r "jcef Helper (Renderer).app" $CEFROOT/macos64/
cp *.dylib $CEFROOT/macos64/
cp *.jar $CEFROOT/
cd $SCRIPTPATH/build

zip -r cef-mac.zip cef

if [ ! -d $SCRIPTPATH/dist ]; then
	mkdir $SCRIPTPATH/dist
fi
mv cef-mac.zip $SCRIPTPATH/dist/


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

MAC64="$CEFROOT/macos64"
CEF_FRAMEWORK="$MAC64/Chromium Embedded Framework.framework"
if [ -d "$CEF_FRAMEWORK" ] && [ ! -d "$CEF_FRAMEWORK/Versions" ]; then
    # The Chromium Embedded Framework comes malformed so Apple won't accept it.
    # We need to fix it to be a valid format
    echo "Fixing structure of $CEF_FRAMEWORK so that Apple doesn't complain"
    mv "$CEF_FRAMEWORK" "${CEF_FRAMEWORK}-tmp"
    mkdir "$CEF_FRAMEWORK"
    mkdir "$CEF_FRAMEWORK/Versions"
    mv "${CEF_FRAMEWORK}-tmp" "$CEF_FRAMEWORK/Versions/A"
    CURR_DIRECTORY=`pwd`
    cd "$CEF_FRAMEWORK/Versions"
    ln -s A Current
    cd ..
    ln -s Versions/Current/Resources Resources
    ln -s Versions/Current/Libraries Libraries
    ln -s Versions/Current/"Chromium Embedded Framework" "Chromium Embedded Framework"
    cd "$CURR_DIRECTORY"


fi
CN1_BUNDLE_IDENTIFIER="com.codenameone.cef"
if [ ! -z "$CN1_BUNDLE_IDENTIFIER" ]; then
    find "$MAC64" -name Info.plist -exec plutil -replace CFBundleIdentifier -string "$CN1_BUNDLE_IDENTIFIER" {} \;
fi
if [ -f "$SCRIPTPATH/codesign-settings.sh" ]; then
  source "$SCRIPTPATH/codesign-settings.sh"
fi
if [ ! -z "$CERT" ]; then

    find "$MAC64" -type f \( -name "*.jar" -or -name "*.dylib" -or -name "*.dylib.*" \) -exec chmod u+w {} \;
    find "$MAC64" -type f \( -name "*.jar" -or -name "*.dylib" -or -name "*.jnilib" -or -name "*.dylib.*" \) -exec codesign --options "$CODESIGN_OPTIONS"  --verbose=4 -f -s "$CERT"  --entitlements "$ENTITLEMENTS" $CN1_CODESIGN_ARGS {} \;
    find "$MAC64" -type f \( -name "*.jar" -or -name "*.dylib" -or -name "*.jnilib" -or -name "*.dylib.*" \) -exec codesign --verbose=4 --verify $CN1_CODESIGN_ARGS {} \;


    codesign --entitlements "$ENTITLEMENTS" --options "$CODESIGN_OPTIONS" --verbose=4 -f -s "$CERT"  $CN1_CODESIGN_ARGS "$CEF_FRAMEWORK/Versions/A/Chromium Embedded Framework"
    codesign --verbose=4 --verify $CN1_CODESIGN_ARGS "$CEF_FRAMEWORK/Versions/A/Chromium Embedded Framework"
    codesign --entitlements "$ENTITLEMENTS" --options "$CODESIGN_OPTIONS" --deep --verbose=4 -f -s "$CERT" $CN1_CODESIGN_ARGS "$CEF_FRAMEWORK/Versions/A"
    codesign --verbose=4 --verify $CN1_CODESIGN_ARGS "$CEF_FRAMEWORK/Versions/A"

    codesign --entitlements "$ENTITLEMENTS" --options "$CODESIGN_OPTIONS" --deep --verbose=4 -f -s "$CERT" $CN1_CODESIGN_ARGS "$MAC64/jcef Helper (GPU).app"
    codesign --entitlements "$ENTITLEMENTS" --options "$CODESIGN_OPTIONS" --deep --verbose=4 -f -s "$CERT" $CN1_CODESIGN_ARGS "$MAC64/jcef Helper (Renderer).app"
    codesign --entitlements "$ENTITLEMENTS" --options "$CODESIGN_OPTIONS" --deep --verbose=4 -f -s "$CERT" $CN1_CODESIGN_ARGS "$MAC64/jcef Helper (Plugin).app"
    codesign --entitlements "$ENTITLEMENTS" --options "$CODESIGN_OPTIONS" --deep --verbose=4 -f -s "$CERT" $CN1_CODESIGN_ARGS "$MAC64/jcef Helper.app"
    NOTARIZE_ZIP="$SCRIPTPATH/build/notarize-bundle.zip"
    ditto -c -k "$MAC64" "$NOTARIZE_ZIP"
    xcrun altool --notarize-app --primary-bundle-id "$CN1_BUNDLE_IDENTIFIER" --username "$APPLE_USER" --password "$APPLE_PASSWORD" --file "$NOTARIZE_ZIP"

fi

cd $SCRIPTPATH/build



zip -r -y cef-mac.zip cef
#ditto -c -k --keepParent cef cef-mac.zip

if [ ! -d $SCRIPTPATH/dist ]; then
	mkdir $SCRIPTPATH/dist
fi
mv cef-mac.zip $SCRIPTPATH/dist/


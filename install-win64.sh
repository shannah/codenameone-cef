#!/bin/sh
set -e
if [ -d ~/.codenameone/cef ]; then
	echo "~/.codenameone/cef directory already exists.  Please move or remove it in order to install a new version"
	exit 1
fi
if [ -d test ]; then
	rm -rf test
fi
if [ ! -d ~/.codenameone ]; then
	mkdir ~/.codenameone
fi
mkdir ~/.codenameone/cef
cp dist/cef-win64.zip ~/.codenameone/cef/
cd ~/.codenameone/cef
jar -xvf cef-win64.zip
rm cef-win64.zip
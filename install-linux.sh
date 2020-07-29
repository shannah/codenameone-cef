#!/bin/sh
set -e
arch="64"

if [ -d ~/.codenameone/cef/lib/linux$arch ]; then
    echo "~/.codenameone/cef/linux$arch directory already exists.  Please move or remove it in order to install a new version"
    exit 1
fi
version=$(<version.txt)
existing_version=0
if [ -f ~/.codenameone/cef/version.txt ]; then
    existing_version=$(<~/.codenameone/cef/version.txt)
fi
if [ -d ~/.codenameone/cef ] && [ "$existing_version" != "$version" ]; then
    echo "~/.codenameone/cef exists and has a different version than the version you're trying to install.  Please move or remove if in order to install a new version"
    exit 1;
fi
if [ -d ~/.codenameone/cef$arch ]; then
    rm -rf ~/.codenameone/cef$arch
fi

if [ -d test ]; then
	rm -rf test
fi
if [ ! -d ~/.codenameone ]; then
	mkdir ~/.codenameone
fi
mkdir ~/.codenameone/cef$arch
cp version.txt ~/.codenameone/cef$arch/

cp dist/cef-linux$arch.zip ~/.codenameone/cef$arch/
cd ~/.codenameone/cef$arch
jar -xvf cef-linux$arch.zip
rm cef-linux$arch.zip

if [ -d ~/.codenameone/cef ]; then
    mv ~/.codenameone/cef$arch/lib/linux$arch ~/.codenameone/cef/lib/linux$arch
    rm -rf ~/.codenameone/cef$arch
else
    mv ~/.codenameone/cef$arch ~/.codenameone/cef
fi
chmod 755 ~/.codenameone/cef/lib/linux64/jcef_helper


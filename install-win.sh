#!/bin/sh
set -e
arch=$1
if [ "$arch" != "64" ] && [ "$arch" != "32" ]; then
    echo "Usage: sh install-win.sh ARCH"
    echo " ARCH = 32 or 64"
    exit 1
fi
if [ -d ~/.codenameone/cef/lib/win$arch ]; then
    echo "~/.codenameone/cef/lib/win$arch directory already exists.  Please move or remove it in order to install a new version"
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

cp dist/cef-win$arch.zip ~/.codenameone/cef$arch/
cd ~/.codenameone/cef$arch
jar -xvf cef-win$arch.zip
rm cef-win$arch.zip

if [ -d ~/.codenameone/cef ]; then
    mv ~/.codenameone/cef$arch/lib/win$arch ~/.codenameone/cef/lib/win$arch
    rm -rf ~/.codenameone/cef$arch
else
    mv ~/.codenameone/cef$arch ~/.codenameone/cef
fi


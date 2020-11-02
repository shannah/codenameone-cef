#!/bin/bash
# A script to download files directly from Google Drive
fileid="$1"
filename="$2"
curl -c ./build/cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
curl -Lb ./build/cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./build/cookie`&id=${fileid}" -o ${filename}
rm ./build/cookie
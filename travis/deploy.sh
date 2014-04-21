#!/bin/bash

# Make backup folder
mkdir $MODULE_ROOT/dist_bak
cp $MODULE_ROOT/ios/*.zip $MODULE_ROOT/dist_bak
cp $MODULE_ROOT/android/dist/*.zip $MODULE_ROOT/dist_bak

# Make destination folder
mkdir $MODULE_ROOT/dist
NAME="${FILENAME%.*}"
EXT="${FILENAME##*.}"
NOW=$(date +"%d%m%Y")

# Copy files with changed names
for FILENAME in $MODULE_ROOT/dist_bak/*.zip
do
  cp "${FILENAME}" "$MODULE_ROOT/dist/${NAME}-${NOW}.${EXT}"
done

# Upload to S3
cd $MODULE_ROOT/dist
travis-artifacts upload --path *.zip --target-path modules/$MODULE_NAME/"

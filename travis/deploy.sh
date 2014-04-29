#!/bin/bash

# Make backup folder
mkdir $MODULE_ROOT/dist_bak

if [ -d "$MODULE_ROOT/ios/" ]; then
  cp -fv $MODULE_ROOT/ios/*.zip $MODULE_ROOT/dist_bak
fi

if [ -d "$MODULE_ROOT/android/" ]; then
  cp -fv $MODULE_ROOT/android/dist/*.zip $MODULE_ROOT/dist_bak
fi

# Make destination folder
mkdir $MODULE_ROOT/dist_upload
NOW=$(date +"%Y%m%d%H%M")

# Copy files with changed names
cd $MODULE_ROOT/dist_bak
for FILENAME in *.zip
do
  echo "${FILENAME}"
  cp -fv "${FILENAME}" "${MODULE_ROOT}/dist_upload/${FILENAME%.*}-${TRAVIS_BRANCH}-${NOW}.${FILENAME##*.}"
done

# Upload to S3
cd $MODULE_ROOT/dist_upload
# Yes, you need to call this once per platform
if [ -d "$MODULE_ROOT/ios/" ]; then
  travis-artifacts upload --path *iphone*.zip --target-path modules/$MODULE_NAME/
fi

if [ -d "$MODULE_ROOT/android/" ]; then
  travis-artifacts upload --path *android*.zip --target-path modules/$MODULE_NAME/
fi
rm -rf dist_bak
rm -rf dist_upload

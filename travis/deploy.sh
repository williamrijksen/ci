#!/bin/bash

# Make backup folder
mkdir $MODULE_ROOT/dist_bak
cp -fv $MODULE_ROOT/ios/*.zip $MODULE_ROOT/dist_bak
cp -fv $MODULE_ROOT/android/dist/*.zip $MODULE_ROOT/dist_bak

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
travis-artifacts upload --path *android*.zip --target-path modules/$MODULE_NAME/
travis-artifacts upload --path *iphone*.zip --target-path modules/$MODULE_NAME/
rm -rf dist_bak
rm -rf dist_upload

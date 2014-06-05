#!/bin/bash

hyperloop package module --cflags=-DHL_DISABLE_CRASH --platform=ios --src=$MODULE_ROOT/ios --dest=$MODULE_ROOT/ios/build —debug

# create a local cloned repo
git clone https://github.com/appcelerator/titanium_mobile.git
sudo easy_install pyyaml
sudo easy_install Pygments
python ./titanium_mobile/apidoc/docgen.py -f modulehtml -o $MODULE_ROOT/build/apidoc/ -e --css styles.css  $MODULE_ROOT/apidoc/

# Navigate to the ios directory of the module project and execute the following commands
# Add additional folders to the module zip
# Make sure to change the version numbers below to match the current version of the module

ROOT_FOLDER=$MODULE_ROOT/ios
mkdir -p $ROOT_FOLDER/modules/iphone/$MODULE_NAME/$MODULE_VERSION
cp -RP $ROOT_FOLDER/build/apidoc $ROOT_FOLDER/modules/iphone/$MODULE_NAME/$MODULE_VERSION/
cp -RP $ROOT_FOLDER/example $ROOT_FOLDER/modules/iphone/$MODULE_NAME/$MODULE_VERSION/
cp -RP $ROOT_FOLDER/documentation $ROOT_FOLDER/modules/iphone/$MODULE_NAME/$MODULE_VERSION/
cp $ROOT_FOLDER/build/$MODULE_NAME-iphone-1.0.0.zip $ROOT_FOLDER/$MODULE_NAME-iphone-$MODULE_VERSION.zip
zip --symlinks -r $ROOT_FOLDER/$MODULE_NAME-iphone-$MODULE_VERSION.zip $ROOT_FOLDER/modules/ -x \*DS_Store

# Cleanup
rm -rf $ROOT_FOLDER/modules

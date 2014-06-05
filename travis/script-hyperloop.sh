#!/bin/bash

hyperloop package module --cflags=-DHL_DISABLE_CRASH --platform=ios --src=$MODULE_ROOT/ios --dest=$MODULE_ROOT/ios/build —debug

# create a local cloned repo
git clone https://github.com/appcelerator/titanium_mobile.git
sudo easy_install pyyaml
python ./titanium_mobile/apidoc/docgen.py -f modulehtml -o $MODULE_ROOT/build/apidoc/ -e --css styles.css  $MODULE_ROOT/apidoc/

# Navigate to the ios directory of the module project and execute the following commands
# Add additional folders to the module zip
# Make sure to change the version numbers below to match the current version of the module

mkdir -p $MODULE_ROOT/modules/iphone/$MODULE_NAME/$MODULE_VERSION
cp -RP $MODULE_ROOT/build/apidoc $MODULE_ROOT/modules/iphone/$MODULE_NAME/$MODULE_VERSION/
cp -RP $MODULE_ROOT/example $MODULE_ROOT/modules/iphone/$MODULE_NAME/$MODULE_VERSION/
cp -RP $MODULE_ROOT/documentation modules/iphone/$MODULE_NAME/$MODULE_VERSION/
cp $MODULE_ROOT/build/$MODULE_NAME-iphone-1.0.0.zip $MODULE_ROOT/$MODULE_NAME-iphone-$MODULE_VERSION.zip
zip --symlinks -r $MODULE_ROOT/$MODULE_NAME-iphone-$MODULE_VERSION.zip $MODULE_ROOT/modules/ -x \*DS_Store

# Cleanup
rm -rf $MODULE_ROOT/modules

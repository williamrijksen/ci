#!/bin/bash

# create a local cloned repo
git clone https://github.com/appcelerator/titanium_mobile.git $TRAVIS_BUILD_DIR/titanium_mobile
export TI_ROOT=$TRAVIS_BUILD_DIR/titanium_mobile

hyperloop package module --platform=ios --src=$MODULE_ROOT/ios --dest=$MODULE_ROOT/ios/build --debug

ls -la

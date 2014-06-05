#!/bin/bash

# create a local cloned repo
git clone https://github.com/appcelerator/titanium_mobile.git
TI_ROOT=./titanium_mobile

hyperloop package module --platform=ios --src=$MODULE_ROOT/ios --dest=$MODULE_ROOT/ios/build —debug

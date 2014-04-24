#!/bin/bash

# If iOS module exists, build
if [ -d "$MODULE_ROOT/ios/" ]; then
  cd $MODULE_ROOT/ios/
  ./build.py
fi

# if Android module exists, build
if [ -d "$MODULE_ROOT/android/" ]; then
  cd $MODULE_ROOT/android/
  cp $MODULE_ROOT/build.properties build.properties

  # if lib folder doesn't exist, create it
  if [ -d "lib" ]; then
    mkdir lib
  fi

  ant clean
  ant
fi

#!/bin/bash

RETSTATUS=0
STATUS=0

# If iOS module exists, build
if [ -d "$MODULE_ROOT/ios/" ]; then

  echo
  echo "Building iOS version"
  echo

  cd $MODULE_ROOT/ios/
  ./build.py

  let STATUS=$?
  if (( "$RETSTATUS" == "0" )) && (( "$STATUS" != "0" )); then
    let RETSTATUS=$STATUS
  fi
fi

# if Android module exists, build
if [ -d "$MODULE_ROOT/android/" ]; then

  echo
  echo "Building Android version"
  echo

  cd $MODULE_ROOT/android/
  cp $MODULE_ROOT/build.properties build.properties
  cat build.properties
  
  # if lib folder doesn't exist, create it
  mkdir -p lib

  ant clean
  ant

  let STATUS=$?
  if (( "$RETSTATUS" == "0" )) && (( "$STATUS" != "0" )); then
    let RETSTATUS=$STATUS
  fi

  cd $MODULE_ROOT
  
fi

exit $RETSTATUS

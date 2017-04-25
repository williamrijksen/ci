#!/bin/bash
# Argument = -sdk 6.0.1.GA
OPTIND=1    # also remember to initialize your flags and other variables

usage()
{
cat << EOF
usage: $0 options

Installs various pre-requisites for building a module.

OPTIONS:
   -h      Show this message
   -s      Version of Titanium SDK to use. If not specified, uses 6.0.1.GA
   -a      Version of Android SDK to install. If not specified, uses 23
EOF
}

export TITANIUM_SDK_VERSION="6.0.1.GA"
export TITANIUM_ANDROID_API="23"
while getopts ":h:s:a:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             TITANIUM_SDK_VERSION=$OPTARG
             ;;
         a)
             TITANIUM_ANDROID_API=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

# Need to install jq to process the JSON
brew update
brew install jq # process JSON

sudo npm install -g titanium
titanium login travisci@appcelerator.com travisci
# titanium sdk install -b master --no-progress-bars

export TITANIUM_ROOT=`ti sdk list -o json | jq -r '.defaultInstallLocation'`
export TITANIUM_SDK=`ti sdk list -o json | jq -r '.installed[.activeSDK]'`
mkdir -p "$TITANIUM_ROOT/sdks/"

# Install artifact uploader
TRAVIS_GEM=`gem list travis-artifacts | grep "travis"`
if [ -z "${TRAVIS_GEM-unset}" ]; then
    gem install travis-artifacts --no-ri --no-rdoc
fi

# install py markdown
export PYTHONPATH=${PYTHONPATH}:$PWD/support
sudo easy_install markdown

# If Android module exists, build
if [ -d "$MODULE_ROOT/android/" ]; then

  # install ANT
  brew install ant

  # Install Android SDK
  echo
  echo "Checking existance of $TITANIUM_ROOT/sdks/android-sdk-macosx"
  echo

  ANDROID_HOME=`ti info -t android -o json | jq -r '.android.sdk.path'`

  if [ ! -d "$ANDROID_HOME" ]; then

    cd "$TITANIUM_ROOT/sdks/"
    wget https://dl.google.com/android/android-sdk_r24.4.1-macosx.zip
    unzip -qq -o android-sdk_r24.4.1-macosx.zip
    ANDROID_HOME=${PWD}/android-sdk-macosx
    titanium config android.sdkPath $ANDROID_HOME

  fi

  export ANDROID_HOME
  export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

  echo "Installing and configuring Android SDK + Tools"

  # Install required Android components.
  # Update tools first so we get latest version of tools and latest repository URL is used to fetch the other packages
  echo yes | android -s update sdk --no-ui --all --filter tools
  echo yes | android -s update sdk --no-ui --all --filter platform-tools
  echo yes | android -s update sdk --no-ui --all --filter build-tools-$TITANIUM_ANDROID_API.0.3
  echo yes | android -s update sdk --no-ui --all --filter android-21 # Need android 21 because module scripts are hard-coded to this for docgen
  echo yes | android -s update sdk --no-ui --all --filter android-$TITANIUM_ANDROID_API
  echo yes | android -s update sdk --no-ui --all --filter addon-google_apis-google-$TITANIUM_ANDROID_API
  echo yes | android -s update sdk --no-ui --all --filter extra-android-support

  # NDK r11c
  echo
  echo "Checking existance of $MODULE_ROOT/android-ndk-r11c"
  echo

  ANDROID_NDK=`ti info -t android -o json | jq -r '.android.ndk.path'`

  if [ ! -d "$ANDROID_NDK" ]; then
    cd "$MODULE_ROOT"
    wget http://dl.google.com/android/repository/android-ndk-r11c-darwin-x86_64.zip
    unzip -q -o android-ndk-r11c-darwin-x86_64.zip
    ANDROID_NDK=${PWD}/android-ndk-r11c
    titanium config android.ndkPath $ANDROID_NDK
  fi

  export ANDROID_NDK

  # Install Java 6 if necessary for get around http://bugs.java.com/bugdatabase/view_bug.do?bug_id=7131356
  java_installed=$( grep "commonjs:\s*true" -c  $MODULE_ROOT/android/manifest )
  if [ $java_installed -gt 0 ]; then
    cd "$MODULE_ROOT"
    wget http://support.apple.com/downloads/DL1572/en_US/javaforosx.dmg
    MOUNTDIR=`hdiutil mount javaforosx.dmg | tail -1 | sed -n 's/.*\(\/Volumes\/Java.*\)/\1/p'`
    sudo installer -pkg "${MOUNTDIR}/JavaForOSX.pkg" -target /
  fi

  # Write out properties file

  echo "titanium.platform=$TITANIUM_SDK/android" > $MODULE_ROOT/build.properties
  echo "android.platform=$ANDROID_HOME/platforms/android-$TITANIUM_ANDROID_API" >> $MODULE_ROOT/build.properties
  echo "google.apis=$ANDROID_HOME/add-ons/addon-google_apis-google-$TITANIUM_ANDROID_API" >> $MODULE_ROOT/build.properties

fi

# If iOS module exists, build
if [ -d "$MODULE_ROOT/ios/" ]; then
  # Write out properties file

  echo "TITANIUM_SDK = $TITANIUM_SDK" > $MODULE_ROOT/titanium.xcconfig
  echo "TITANIUM_BASE_SDK = \"\$(TITANIUM_SDK)/iphone/include\"" >> $MODULE_ROOT/titanium.xcconfig
  echo "TITANIUM_BASE_SDK2 = \"\$(TITANIUM_SDK)/iphone/include/TiCore\"" >> $MODULE_ROOT/titanium.xcconfig
  echo "TITANIUM_BASE_SDK3 = \"\$(TITANIUM_SDK)/iphone/include/ASI\"" >> $MODULE_ROOT/titanium.xcconfig
  echo "TITANIUM_BASE_SDK4 = \"\$(TITANIUM_SDK)/iphone/include/APSHTTPClient\"" >> $MODULE_ROOT/titanium.xcconfig
  echo "HEADER_SEARCH_PATHS= \$(TITANIUM_BASE_SDK) \$(TITANIUM_BASE_SDK2) \$(TITANIUM_BASE_SDK3) \$(TITANIUM_BASE_SDK4) \${PROJECT_DIR}/**" >> $MODULE_ROOT/titanium.xcconfig

fi

titanium info

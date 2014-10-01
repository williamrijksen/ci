#!/bin/bash
# Argument = -sdk 3.1.2.GA
OPTIND=1    # also remember to initialize your flags and other variables

usage()
{
cat << EOF
usage: $0 options

Installs various pre-requisites for building a module.

OPTIONS:
   -h      Show this message
   -s      Version of Titanium SDK to use. If not specified, uses 2.1.3.GA
   -a      Version of Android SDK to install. If not specified, used 10
EOF
}

export TITANIUM_SDK="2.1.3.GA"
export TITANIUM_ANDROID_API="10"
while getopts “hs:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         s)
             TITANIUM_SDK=$OPTARG
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

export TITANIUM_ROOT="$HOME/Library/Application Support/Titanium"
mkdir -p "$TITANIUM_ROOT/sdks/"

echo
echo "TITANIUM_SDK=$TITANIUM_SDK"
echo "TITANIUM_ANDROID_API=$TITANIUM_ANDROID_API"
echo "TITANIUM_ROOT=$TITANIUM_ROOT"
echo "MODULE_ROOT=$MODULE_ROOT"
echo

cd $MODULE_ROOT

# Install artifact uploader
gem install travis-artifacts --no-ri --no-rdoc

# install py markdown
export PYTHONPATH=${PYTHONPATH}:$PWD/support
sudo easy_install markdown

sudo npm install -g titanium
titanium login travisci@appcelerator.com travisci


# If Android module exists, build
if [ -d "$MODULE_ROOT/android/" ]; then

  # install ANT
  brew update
  brew install ant

  # Install Android SDK
  echo
  echo "Checking existance of $TITANIUM_ROOT/sdks/android-sdk-macosx"
  echo

  if [ ! -d "$TITANIUM_ROOT/sdks/android-sdk-macosx" ]; then

    cd "$TITANIUM_ROOT/sdks/"
    wget http://dl.google.com/android/android-sdk_r23.0.2-macosx.zip
    unzip -qq -o android-sdk_r23.0.2-macosx.zip

  fi

  export ANDROID_HOME=${PWD}/android-sdk-macosx
  export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
  
  echo "Installing and configuring Android SDK + Tools"

  # Install required Android components.
  echo yes | android -s update sdk --no-ui --all --filter \
    tools
  echo yes | android -s update sdk --no-ui --all --filter \
    platform-tools
  echo yes | android -s update sdk --no-ui --all --filter \
    extra-android-support 
  echo yes | android -s update sdk --no-ui --all --filter \
    android-8
  echo yes | android -s update sdk --no-ui --all --filter \
    android-$TITANIUM_ANDROID_API
  echo yes | android -s update sdk --no-ui --all --filter \
    addon-google_apis-google-$TITANIUM_ANDROID_API
    
  # Install require Android NDK
  cd $MODULE_ROOT

  # NDK r8c
  echo
  echo "Checking existance of $MODULE_ROOT/android-ndk-r8c"
  echo

  if [ ! -d "$MODULE_ROOT/android-ndk-r8c" ]; then
    wget http://dl.google.com/android/ndk/android-ndk-r8c-darwin-x86.tar.bz2
    tar xzf android-ndk-r8c-darwin-x86.tar.bz2
  fi

  export ANDROID_NDK=${PWD}/android-ndk-r8c

  # Write out properties file
 
  echo "titanium.platform=$TITANIUM_ROOT/mobilesdk/osx/$TITANIUM_SDK/android" > build.properties
  echo "android.platform=$TITANIUM_ROOT/sdks/android-sdk-macosx/platforms/android-$TITANIUM_ANDROID_API" >> build.properties
  echo "google.apis=$TITANIUM_ROOT/sdks/android-sdk-macosx/add-ons/addon-google_apis-google-$TITANIUM_ANDROID_API" >> build.properties
  
  titanium config android.sdkPath $ANDROID_HOME
fi

# Android SDK seems to require newer version of SDK
echo
echo "Checking existance of $TITANIUM_ROOT/mobilesdk/osx/$TITANIUM_SDK"
echo

titanium sdk install "3.4.0.GA" --no-progress-bars

if [ ! -d "$TITANIUM_ROOT/mobilesdk/osx/$TITANIUM_SDK" ]; then

   titanium sdk install $TITANIUM_SDK --no-progress-bars
   TITANIUM_SDK=`ls "$TITANIUM_ROOT/mobilesdk/osx/"`

fi

titanium info

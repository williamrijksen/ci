#!/bin/bash
# Argument = -sdk 3.1.2.GA

usage()
{
cat << EOF
usage: $0 options

Installs various pre-requisites for building a module.

OPTIONS:
   -h      Show this message
   -s      Version of Titanium SDK to use. If not specified, uses 2.1.3.GA
EOF
}

export TITANIUM_SDK="2.1.3.GA"
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
         ?)
             usage
             exit
             ;;
     esac
done

echo
echo "Building with version $TITANIUM_SDK of Titanium"
echo

cd $MODULE_ROOT

# Install artifact uploader
gem install travis-artifacts

sudo mkdir -p ~/Library/Application\ Support/Titanium/sdks/

# install py markdown
export PYTHONPATH=${PYTHONPATH}:$PWD/support
sudo easy_install markdown

# install ANT
brew install ant

# Android SDK seems to require newer version of SDK
sudo wget http://api.appcelerator.net/p/v1/release-download?token=34yycjh6 -O /Library/Application\ Support/Titanium/mobilesdk-$TITANIUM_SDK-osx.zip
cd ~/Library/Application\ Support/Titanium/
sudo unzip -o  mobilesdk-$TITANIUM_SDK-osx.zip

# IOS uses v.1.6
#sudo wget http://api.appcelerator.net/p/v1/release-download?token=y4qAVWK3 -O /Library/Application\ Support/Titanium/mobilesdk-1.6.0-osx.zip
#cd /Library/Application\ Support/Titanium/
#sudo unzip -o mobilesdk-1.6.0-osx.zip

# Install Android SDK
cd ~/Library/Application\ Support/Titanium/sdks/
sudo wget http://dl.google.com/android/android-sdk_r22.6.2-macosx.zip
sudo unzip -o android-sdk_r22.6.2-macosx.zip
export ANDROID_HOME=${PWD}/android-sdk-macosx

export PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install required Android components.
echo "y" | android update sdk --filter platform-tools,android-8,android-10,addon-google_apis-google-10,extra-android-support,$ANDROID_SDKS --no-ui --force

# Install require Android NDK
cd $MODULE_ROOT
# NDK r9d
#- wget http://dl.google.com/android/ndk/android-ndk-r9d-darwin-x86.tar.bz2
#- tar xzf android-ndk-r9d-darwin-x86.tar.bz2
#- export ANDROID_NDK=${PWD}/android-ndk-r9d

# NDK r8c
wget http://dl.google.com/android/ndk/android-ndk-r8c-darwin-x86.tar.bz2
tar xzf android-ndk-r8c-darwin-x86.tar.bz2
export ANDROID_NDK=${PWD}/android-ndk-r8c

# Write out properties file
echo "titanium.platform=/Library/Application Support/Titanium/mobilesdk/osx/2.1.3.GA/android" >> build.properties
echo "android.platform=/Library/Application Support/Titanium/sdks/android-sdk-macosx/platforms/android-10" >> build.properties
echo "google.apis=/Library/Application Support/Titanium/sdks/android-sdk-macosx/add-ons/addon-google_apis-google-10" >> build.properties

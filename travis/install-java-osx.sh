#!/bin/bash

wget http://support.apple.com/downloads/DL1572/en_US/javaforosx.dmg
ls -la
MOUNTDIR=`hdiutil mount javaforosx.dmg | tail -1 | sed -n 's/.*\(\/Volumes\/Java.*\)/\1/p'`
hdiutil info
sudo installer -pkg "${MOUNTDIR}/JavaForOSX.pkg" -target /

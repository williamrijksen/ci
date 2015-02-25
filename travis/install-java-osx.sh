#!/bin/bash

wget http://support.apple.com/downloads/DL1572/en_US/JavaForOSX2014-001.dmg
MOUNTDIR=`hdiutil mount JavaForOSX2014-001.dmg -mountroot /Volumes/Java | tail -1 | sed -n 's/.*\(\/Volumes\/Java.*\)/\1/p'`
sudo installer -pkg "${MOUNTDIR}/JavaForOSX.pkg" -target /

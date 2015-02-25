#!/bin/bash

wget http://support.apple.com/downloads/DL1572/en_US/JavaForOSX2014-001.dmg
ls -la
MOUNTDIR=`hdiutil mount JavaForOSX2014-001.dmg | tail -1 | sed -n 's/.*\(\/Volumes\/Java.*\)/\1/p'`
hdiutil info
sudo installer -pkg "${MOUNTDIR}/JavaForOSX.pkg" -target /

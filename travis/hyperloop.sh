#!/bin/bash

# create a local cloned repo
git clone https://github.com/appcelerator/hyperloop.git

# change to the new directory
cd hyperloop

# install dependencies locally
npm install

# link your PATH to the locally installed hyperloop. This removes the need to `npm install` after changes
sudo npm link

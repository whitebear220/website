#!/bin/bash
apt install npm nodejs-legacy -y
npm install
node app.js &
echo "Start node.js"

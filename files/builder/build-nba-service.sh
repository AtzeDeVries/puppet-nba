#!/bin/sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <branch> <target> (install-service/install-etl)" >&2
  exit 1
fi

echo "Injecting github credentials if available"
sh /prepare-git.sh

echo "Cloning repository to /source"
git clone --single-branch --branch $1 https://github.com/naturalis/naturalis_data_api /source

#echo "Checkout to branch V2_master"
#cd /source
#git checkout V2_master

echo "Entering build directory"
cd /source/nl.naturalis.nba.build

echo "Adding build.v2.properties"
cp /build.v2.properties ./

echo "Kickof build"
ant $2

if [ $? -eq 0 ]
then
  echo "Successfully ran $2"
  exit 0
else
  echo "Error building $2"
  exit 1
fi

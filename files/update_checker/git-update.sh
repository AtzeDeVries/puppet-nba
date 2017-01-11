#!/bin/sh

PREV=".git-status"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 Git-URL branch" >&2
  exit 1
fi

REPO=$(basename $1)
PREVFILE=$PREV-$REPO-$2
CURR_COMMIT=$(git ls-remote $1 --head $2 2> /dev/null | awk '{print $1}')

if [ -z $CURR_COMMIT ]
then
  echo "Error: Unable to check repo. Repo is probally private and creds are incorrect"
  exit 1
fi


if [ ! -f $PREVFILE ]
then
  echo "Difference"
  echo $CURR_COMMIT > $PREVFILE
  #git ls-remote $1 --head $2 2> /dev/null | awk '{print $1}' > $PREVFILE
  exit
fi

PREV_COMMIT=$(cat $PREVFILE)

if [ "$PREV_COMMIT" == "$CURR_COMMIT" ]
then
  echo "Same"
else
  echo "Difference"
fi

echo $CURR_COMMIT > $PREVFILE

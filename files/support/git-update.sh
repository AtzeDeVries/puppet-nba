#!/bin/sh

PREV=".git-status"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 Git-URL branch" >&2
  exit 1
fi

REPO=$(basename $1)
PREVFILE=$PREV-$REPO-$2

if [ ! -f $PREVFILE ] ; then
  echo "Difference"
  git ls-remote $1 --head $2 | awk '{print $1}' > $PREVFILE
  exit
fi

PREV_COMMIT=$(cat $PREVFILE)
CURR_COMMIT=$(git ls-remote $1 --head $2 | awk '{print $1}')

if [ "$PREV_COMMIT" == "$CURR_COMMIT" ] ; then
  echo "Same"
else
  echo "Difference"
fi

echo $CURR_COMMIT > $PREVFILE

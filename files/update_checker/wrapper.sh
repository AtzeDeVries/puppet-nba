#!/bin/sh
sh /prepare-git.sh > /dev/null
sh /git-update.sh $*

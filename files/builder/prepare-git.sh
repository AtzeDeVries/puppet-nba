#!/bin/sh

#Support username/password
if [ "$GITHUB_USER" ] ; then
  echo "machine github.com" > ~/.netrc
  echo "\t login $GITHUB_USER" >> ~/.netrc
  echo "\t password $GITHUB_PASS" >> ~/.netrc
  echo "Injected username password to ~/.netrc"
fi

if [ "$SSHKEY" ] ; then
  mkdir ~/.ssh
  echo "$SSHKEY" > ~/.ssh/id_rsa
  ssh-keyscan github.com > ~/.ssh/known_hosts
  "Injected ssh key to ~/.ssh/known_hosts"
fi

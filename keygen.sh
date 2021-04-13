#!/usr/bin/bash

existing_keys()
{
  gpg --list-secret-keys --keyid-format LONG | grep ^sec | while read -r line ; do
    KEY_TYPE_ID=$(eval "echo $line | awk '{print \$2}'")
    KEY_TYPE=$(eval "echo $KEY_TYPE_ID | cut -d '/' -f1")
    KEY_ID=$(eval "echo $KEY_TYPE_ID | cut -d '/' -f2")
    echo $KEY_TYPE $KEY_ID
  done 
}


if gpg --list-secret-keys --keyid-format LONG | grep -q ^sec ; then
	echo "existing gpg keys found"
  existing_keys
else
	echo "no gpg keys found"
  echo "creating a new one"
  # create key
  existing_keys
fi


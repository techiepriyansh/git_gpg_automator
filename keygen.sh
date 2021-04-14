#!/usr/bin/bash

existing_keys()
{
  keys_id=()
  keys_info=()
  keys_cred_info=()
  mapfile -t keys_info < <( gpg --list-secret-keys --keyid-format LONG | grep ^sec | cut -c 4- | awk '{$1=$1};1' )
  mapfile -t keys_cred_info < <( gpg --list-secret-keys --keyid-format LONG | grep ^uid | cut -c 4- | awk '{$1=$1};1' )

  for line in "${keys_info[@]}" ; do
    keys_id+=$(eval "echo $line | cut -d ' ' -f1 |cut -d '/' -f2")
  done

  echo "${keys_id[@]}"
  echo "${keys_info[@]}"
  echo "${keys_cred_info[@]}"
  # keys=($(gpg --list-secret-keys --keyid-format LONG | grep ^sec))
  # keys_id=()
  # keys_type=()
  # for i in "${!keys[@]}" ; do
  #   flag=$(eval "expr $i % 6")
  #   if [ "$flag" = "1" ] ; then
  #     KEY_TYPE_ID=${keys[$i]}
  #     keys_type+=$(eval "echo $KEY_TYPE_ID | cut -d '/' -f1")
  #     keys_id+=$(eval "echo $KEY_TYPE_ID | cut -d '/' -f2")
  #   fi
  # done
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


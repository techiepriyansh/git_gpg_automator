#!/usr/bin/bash

set_signing_key()
{
  keyid=$1
  echo "Configuring git to use the gpg key with id $keyid"
  git config --global user.signingkey $keyid
}

new_key()
{
  gpg --default-new-key-algo rsa4096 --gen-key
}

existing_keys()
{
  keys_id=()
  keys_info=()
  keys_cred_info=()

  mapfile -t keys_info < <( gpg --list-secret-keys --keyid-format LONG | grep ^sec | cut -c 4- | awk '{$1=$1};1' )
  mapfile -t keys_cred_info < <( gpg --list-secret-keys --keyid-format LONG | grep ^uid | cut -c 4- | awk '{$1=$1};1' )

  i=0
  while [ "$i" -lt "${#keys_info[@]}" ] ; do
    num=`expr $i + 1`

    echo "Key [$num]: "
    echo "  " "${keys_cred_info[$i]}"
    echo "  " "${keys_info[$i]}"
    echo

    line=${keys_info[$i]}
    keys_id+=$(eval "echo $line | cut -d ' ' -f1 |cut -d '/' -f2")

    let i=i+1
  done

  echo "Which key would you like to use?"
  read -p "Type its index(1/2/...) or press F to create a new one: " inpt
  
  if [ "$inpt" = "F" ] || [ "$inpt" = "f" ] ; then
    echo
    echo "Creating a new key..."
    if new_key ; then
      echo "New key created successfully"
      existing_keys
    fi
  elif ! [[ "$inpt" =~ ^[0-9]+$ ]] ; then
    echo
    echo "Invalid input!"
    echo "Retry"
    echo
    existing_keys
  elif [ "$inpt" -gt "${#keys_info[@]}" ] || [ "$inpt" = "0" ] ; then
    echo
    echo "Invalid input!"
    echo "Retry"
    echo
    existing_keys
  else
    idx=`expr $inpt - 1`
    set_signing_key ${keys_id[$idx]}
  fi
}


echo "Searching for existing gpg keys..."

if gpg --list-secret-keys --keyid-format LONG | grep -q ^sec ; then
  echo "Existing gpg keys found!"
  echo
  existing_keys
else
  echo "No gpg keys found!"
  echo "Creating a new one..."
  if new_key ; then
    echo "New key created successfully"
    existing_keys
  fi
fi

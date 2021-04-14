#!/bin/bash

set_signing_key()
{
  keyid=$1
  echo "Configuring git to use the gpg key with id $keyid"
  git config --global user.signingkey $keyid
  echo "Done!"
}

new_key()
{
  printf "\nCreating a new key...\n"
  if gpg --default-new-key-algo rsa4096 --gen-key ; then
    echo "New key created successfully!"
  fi
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
    keys_id[$i]=$(eval "echo $line | cut -d ' ' -f1 | cut -d '/' -f2")

    let i=i+1
  done

  echo "Which key would you like to use?"
  read -p "Type its index(1/2/...) or press F to create a new one: " inpt
  
  if [ "$inpt" = "F" ] || [ "$inpt" = "f" ] ; then
    if new_key ; then
      existing_keys
    fi
  elif ! [[ "$inpt" =~ ^[0-9]+$ ]] ; then
    printf "\nInvalid input!\nRetry\n\n"
    existing_keys
  elif [ "$inpt" -gt "${#keys_info[@]}" ] || [ "$inpt" = "0" ] ; then
    printf "\nInvalid input!\nRetry\n\n"
    existing_keys
  else
    idx=`expr $inpt - 1`
    set_signing_key ${keys_id[$idx]}
  fi
}


echo "Searching for existing gpg keys..."

if gpg --list-secret-keys --keyid-format LONG | grep -q ^sec ; then
  printf "Existing gpg keys found!\n\n"
  existing_keys
else
  echo "No gpg keys found!"
  if new_key ; then
    existing_keys
  fi
fi

#!/usr/bin/env bash

while read page_size
do
  if [[ $page_size =~ ^[0-9]+$ ]]; then
    echo $(($page_size / 1024))
  else
    echo "NULL"
  fi
done

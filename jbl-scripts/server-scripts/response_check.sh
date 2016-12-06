#!/bin/bash

#mysql -h admin.justbuylive.in -u $USER -p$PASS -P 3309 processlist
nc -z admin.justbuylive.in 80

if [ $? -eq 0 ]
 then
  date
  echo "responding"
 else
  date
  echo "not responding !"
fi

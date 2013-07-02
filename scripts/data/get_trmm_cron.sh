#!/bin/bash

# Code directory.
CODEDIR="$CINT/bash"

echo "Code dir is $CODEDIR"

# Get last month.
#y=$(/usr/bin/ssh -x kskuo@gpmmodel 'date -d"last month" "+%G"')
#m=$(/usr/bin/ssh -x kskuo@gpmmodel 'date -d"last month" "+%m"')
#m=$(echo $m | bc)

y="2007"
m="1"
$CODEDIR/get_trmm.sh $y $m
exit 0

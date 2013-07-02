#y=$(/usr/bin/ssh -x kskuo@gpmmodel 'date -d"last month" "+%G"')
#startDOY=$(/usr/bin/ssh -x kskuo@gpmmodel 'date +%j -d `date -d"last month" "+%m/01/%Y"`')
#endDOY=$(/usr/bin/ssh -x kskuo@gpmmodel 'date +%j -d `date -d"this month" "+%m/01/%Y"`')

y="2007"
startDOY="2"
endDOY="2"

./run_intersect.sh "$MCRHOME" "$CINTDATA" y startDOY endDOY "0.25" "0.1" "300"

# Remove uncompressed files after running
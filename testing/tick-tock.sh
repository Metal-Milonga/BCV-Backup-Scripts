#!/usr/bin/ksh

TCOUNT=0

while [ $TCOUNT -le 120 ]
do
echo "$(date) \r\c"
sleep 1
TCOUNT=$((TCOUNT + 1))
done

#!/usr/bin/ksh

touch /tmp/crontest.txt

print Testing cron >> /tmp/crontest.txt
print $(date) >> /tmp/crontest.txt
print >> /tmp/crontest.txt

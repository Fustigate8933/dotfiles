#!/bin/sh

case $1 in
    "--used")
        free -m | grep -v Swap | awk 'NR==2{printf "%.2f", $3/$2*100}'
        ;;
    "--all")
        free -t --mega | grep Total | awk '{printf $2/100}'
        ;;
    "--parsed")
        free -t -h --si | grep Total | awk '{printf $3 "b/" $2 "b"}'
        ;;
    *)
        true
        ;;
esac

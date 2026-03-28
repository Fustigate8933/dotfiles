#!/bin/bash

# This script extracts CPU usage and prints it without the percentage sign.
awk -Fid '/Cpu/ { 
    split($1, a, ","); 
    print 100 - a[length(a)] 
}' < <(top -b -n 1)


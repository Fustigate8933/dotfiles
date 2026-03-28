#!/usr/bin/env bash


result=$(eww get show_calendar)

# Check if the result is false
if [ "$result" == "false" ]; then
    # If false, update show_calendar to true
    eww update show_calendar=true
    eww open cal
else
    # If true, update show_calendar to false
    eww close cal
    eww update show_calendar=false
fi

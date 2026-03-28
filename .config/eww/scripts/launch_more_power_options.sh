#!/usr/bin/env bash


result=$(eww get show_more_power_options)

# Check if the result is false
if [ "$result" == "false" ]; then
    # If false, update show_calendar to true
    eww update show_more_power_options=true
    eww open more_power_options
else
    # If true, update show_calendar to false
    eww close more_power_options
    eww update show_more_power_options=false
fi

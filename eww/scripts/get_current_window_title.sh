#!/bin/bash

# Initialize variables
previous_title=""

# Infinite loop to continuously check for the active window title
while true; do
  # Get the current active window title
  current_title=$(hyprctl activewindow | grep 'title:' | cut -d' ' -f2-)
  
  # Check if the title has changed
  if [[ "$current_title" != "$previous_title" ]]; then
    # Truncate the title if it's longer than 40 characters
    if [[ ${#current_title} -gt 33 ]]; then
      truncated_title="${current_title:0:37}..."
    else
      truncated_title="$current_title"
    fi
    
    # Output the new (possibly truncated) title
    echo "$truncated_title"
    # Update the previous title
    previous_title="$current_title"
  fi
  
  # Wait for 2 seconds before checking again
done


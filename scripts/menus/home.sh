#!/bin/bash

option_headers=(
'Open the projects list.'
'Quit.'
)

echo 'Select an action:'

# Display options
for option_idx in "${!option_headers[@]}"; do
  echo "$((option_idx + 1)). ${option_headers[$option_idx]}"
done

# Read user's selected option from the input
echo
read -p "Enter choise: " selected_option

# Import functions for validation
source '../validation.sh'

# Check if the input is a positive integer
if ! is_positive_integer "$selected_option"; then
  message_color='\e[1;31m'
  message='Failure: Input is not a positive integer! Try again.'
  return 0
fi

# Execute the selected action
case $selected_option in
  1)
    location_name="sections"
    ;;
  2)
    location_name=""
    ;;
  *)
    message_color="\e[1;31m"
    message="Failure: Choise must be between 1 and ${#option_headers[@]}. Try again."
    return 0
esac

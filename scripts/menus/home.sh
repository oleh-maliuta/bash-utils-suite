#!/bin/bash

option_headers=(
  'Open the projects list.'
  'Quit.'
)
option_colors=('36' '31')

echo 'Select an action:'

# Display options
for option_idx in "${!option_headers[@]}"; do
  option_color="${option_colors[$option_idx]}"
  echo -e "\e[1;${option_color}m$((option_idx + 1))\e[0;${option_color}m. ${option_headers[$option_idx]}\e[0m"
done

# Read user's selected option from the input
echo
read -p "Enter choice: " selected_option

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
  message="Failure: Choice must be between 1 and ${#option_headers[@]}. Try again."
  return 0
  ;;
esac

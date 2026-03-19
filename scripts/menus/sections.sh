#!/bin/bash

echo 'Select a project section:'

section_count=1
declare -A section_numbers

# Display project sections
for section in ../../projects/*/; do
  folder="${section%/}"
  folder="${folder##*/}"
  echo -e "\e[1;36m$section_count\e[0;36m. \"$folder\"\e[0m"
  section_numbers[$section_count]=$folder
  ((section_count++))
done

# Display the option to go back to the main menu
echo -e "\e[1;31m$section_count\e[0;31m. Go back to the main menu.\e[0m"

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

if ((\
  selected_option >= 1 && \
  selected_option < section_count)) \
    ; then
  selected_section="${section_numbers[$selected_option]}"
  location_name='projects'
elif ((selected_option == section_count)); then
  location_name='home'
else
  message_color='\e[1;31m'
  message="Failure: Choice must be between 1 and ${section_count}. Try again."
  return 0
fi

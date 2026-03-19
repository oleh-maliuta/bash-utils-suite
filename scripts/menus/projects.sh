#!/bin/bash

echo 'Select a project:'

project_count=1
declare -A project_numbers

# Display projects
for project in ../../projects/"$selected_section"/*/; do
  folder="${project%/}"
  folder="${folder##*/}"
  echo -e "\e[1;36m$project_count\e[0;36m. \"$folder\"\e[0m"
  project_numbers[$project_count]=$folder
  ((project_count++))
done

# Display the option to go back to the sections list menu
echo -e "\e[1;31m$project_count\e[0;31m. Go back to the sections list menu.\e[0m"

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
  selected_option < project_count)) \
    ; then
  selected_project="${project_numbers[$selected_option]}"
  location_name='manage_project'
elif ((selected_option == project_count)); then
  location_name='sections'
else
  message_color='\e[1;31m'
  message="Failure: Choice must be between 1 and ${project_count}. Try again."
  return 0
fi

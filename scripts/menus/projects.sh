#!/bin/bash

echo 'Select a project:'

project_count=1
declare -A  project_numbers

# Display projects
for project in ../../projects/"$selected_section"/*/; do
  folder="${project%/}"
  folder="${folder##*/}"
  echo "$project_count. '$folder'"
  project_numbers[$project_count]=$folder
  ((project_count++))
done

# Display the option to go back to the sections list menu
echo "$project_count. Go back to the sections list menu."

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

if ((
  selected_option >= 1 &&
  selected_option < project_count
)); then
  selected_project="${project_numbers[$selected_option]}"
  location_name='manage_project'
elif (( selected_option == project_count )); then
  location_name='sections'
else
  message_color='\e[1;31m'
  message="Failure: Choise must be between 1 and ${project_count}. Try again."
  return 0
fi

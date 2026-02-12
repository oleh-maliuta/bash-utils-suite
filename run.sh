#!/bin/bash

# Variables that are available for the current and the child scripts
export location_name="home"
export message_color="\e[1;32m"
export message="Welcome to the list of my experemental Bash projects!"
export selected_section=""
export selected_project=""

# Navigate to the menus directory
cd scripts/menus

while [ -n "$location_name" ]; do

  # Display the message
  clear
  if [ -n "$message" ]; then
    echo -e "$message_color$message\e[0m"
    echo
  fi

  # Remove the message
  message=""

  # Variables to display the location
  location_path=()
  path_delimiter=" -> "

  # Set the path depending on the current location
  case "$location_name" in
    home)
      location_path=("Home")
      ;;
    sections)
      location_path=("Home" "Sections")
      ;;
    projects)
      location_path=("Home" "Sections" "$selected_section")
      ;;
    manage_project)
      location_path=("Home" "Sections" "$selected_section" "$selected_project")
      ;;
    *)
      clear
      echo -e "\e[1;31mError:\e[0m Invalid location_name variable!"
      exit 1
  esac

  # Prepare the location path to display
  printf -v path_display "%s$path_delimiter" "${location_path[@]}"
  path_display="${path_display%$path_delimiter}"

  # Display the location path
  echo -e "\e[1;34mLocation:\e[0m \e[1;32m\e[44m $path_display \e[0m"
  echo

  # Run the current menu script
  source ./"$location_name".sh

done

# Display when the user quits the main script
clear
echo 'Exited the script.'

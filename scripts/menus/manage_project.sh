#!/bin/bash

option_headers=(
  'Install (current user).'
  'Install (all users).'
  'Uninstall.'
  'Test.'
  'Go back to the projects list menu.'
)
option_colors=('36' '32' '35' '33' '31')

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
  temp_file=$(mktemp)
  script -q -c "../install_script.sh '../../projects/${selected_section}/${selected_project}' -l" "$temp_file"
  message_color="\e[0m"
  message=$(sed '1d; $d' "$temp_file")
  rm "$temp_file"
  ;;
2)
  temp_file=$(mktemp)
  script -q -c "../install_script.sh '../../projects/${selected_section}/${selected_project}' -g" "$temp_file"
  message_color="\e[0m"
  message=$(sed '1d; $d' "$temp_file")
  rm "$temp_file"
  ;;
3)
  temp_file=$(mktemp)
  script -q -c "../uninstall_script.sh '../../projects/${selected_section}/${selected_project}'" "$temp_file"
  message_color="\e[0m"
  message=$(sed '1d; $d' "$temp_file")
  rm "$temp_file"
  ;;
4)
  current_path=$(pwd)
  install_venv_requirements=false
  cd ../..
  if [[ ! -d ./.venv/ ]]; then
    python3 -m venv .venv
    if [[ $? -ne 0 ]]; then
      ./scripts/install_packages.sh python3-venv
      python3 -m venv .venv
    fi
    install_venv_requirements=true
  fi
  source .venv/bin/activate
  if [[ "$install_venv_requirements" == true ]]; then
    pip3 install -r requirements.txt
  fi
  cd projects/"$selected_section"/"$selected_project"
  message_color="\e[0m"
  message=$(pytest -v test.py)
  deactivate
  cd "$current_path"
  ;;
5)
  location_name="projects"
  ;;
*)
  message_color="\e[1;31m"
  message="Failure: Choice must be between 1 and ${#option_headers[@]}. Try again."
  return 0
  ;;
esac

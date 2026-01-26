#!/bin/bash

# --- Variables ---

test_dir='./test'

images=(
"image1.jpg"
"image2.png"
"image3.svg"
)
videos=(
"video1.mp4"
"video2.avi"
"video3.mov"
)
documents=(
"document1.doc"
"document2.docx"
"document3.pdf"
)
others=(
"other1.c"
"other2.asm"
"other3.cs"
)

all_files=(
"${images[@]}"
"${videos[@]}"
"${documents[@]}"
"${others[@]}"
)

# --- Helper Functions ---

setup() {
  mkdir -p "$test_dir"
}

terminate() {
  rm -rf "$test_dir"
}

print_passed() {
  echo -e "\e[1;32m[PASSED]\e[0m"
}

print_failed() {
  echo -e "\e[1;31m[FAILED]\e[0m $1"
}

assert_file_exists() {
  if [[ -f "$1" ]]; then
    return 0
  fi

  return 1
}

# --- Test Cases ---

test_basic_organization() {
  echo '--- Test 1: Basic Organization ---'
  setup

  # Create dummy files
  for file in "${all_files[@]}"; do
    touch "${test_dir}/${file}"
  done

  # Run the script
  ./run.sh "$test_dir" &>/dev/null

  # Validate
  for file in "${images[@]}"; do
    local file_path="${test_dir}/Images/${file}"
    if ! assert_file_exists "$file_path"; then
      print_failed "There is no such file ($file_path)."
      terminate
      return 1
    fi
  done

  for file in "${videos[@]}"; do
    local file_path="${test_dir}/Videos/${file}"
    if ! assert_file_exists "$file_path"; then
      print_failed "There is no such file ($file_path)."
      terminate
      return 1
    fi
  done

  for file in "${documents[@]}"; do
    local file_path="${test_dir}/Documents/${file}"
    if ! assert_file_exists "$file_path"; then
      print_failed "There is no such file ($file_path)."
      terminate
      return 1
    fi
  done

  for file in "${others[@]}"; do
    local file_path="${test_dir}/Others/${file}"
    if ! assert_file_exists "$file_path"; then
      print_failed "There is no such file ($file_path)."
      terminate
      return 1
    fi
  done


  local shouldnt_exist="${test_dir}/Images/video1.mp4"
  if assert_file_exists "$shouldnt_exist"; then
    print_failed "This file shouldn't exist ($shouldnt_exist)."
    terminate
    return 1
  fi

  print_passed
  terminate
  return 0
}

# --- Execution ---

test_basic_organization

#!/bin/bash

# --- Variables ---

error_msg=''

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

# --- Helper Functions ---

before_each() {
  local all_files=(
    "${images[@]}"
    "${videos[@]}"
    "${documents[@]}"
    "${others[@]}"
  )

  # Create the test directory
  mkdir -p "$test_dir"

  # Create dummy files
  for file in "${all_files[@]}"; do
    touch "${test_dir}/${file}"
  done

}

after_each() {
  # Remove the test directory and the dummy files
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
  # Run the script
  ./run.sh "$test_dir"

  # Validate
  for file in "${images[@]}"; do
    local file_path="${test_dir}/Images/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${videos[@]}"; do
    local file_path="${test_dir}/Videos/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${documents[@]}"; do
    local file_path="${test_dir}/Documents/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${others[@]}"; do
    local file_path="${test_dir}/Others/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  local shouldnt_exist="${test_dir}/Images/video1.mp4"
  if assert_file_exists "$shouldnt_exist"; then
    error_msg="This file shouldn't exist ($shouldnt_exist)."
    return
  fi
}

test_category_excluding() {
  # Run the script
  ./run.sh "$test_dir" -e 'Images,Documents'

  # Validate
  for file in "${images[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${videos[@]}"; do
    local file_path="${test_dir}/Videos/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${documents[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${others[@]}"; do
    local file_path="${test_dir}/Others/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  local shouldnt_exist="${test_dir}/video1.mp4"
  if assert_file_exists "$shouldnt_exist"; then
    error_msg="This file shouldn't exist ($shouldnt_exist)."
    return
  fi
}

test_others_dir_excluding() {
  # Run the script
  ./run.sh "$test_dir" -e "Videos,Others"

  # Validate
  for file in "${images[@]}"; do
    local file_path="${test_dir}/Images/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${videos[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${documents[@]}"; do
    local file_path="${test_dir}/Documents/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${others[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  local shouldnt_exist="${test_dir}/Others/video1.mp4"
  if assert_file_exists "$shouldnt_exist"; then
    error_msg="This file shouldn't exist ($shouldnt_exist)."
    return
  fi
}

test_extension_ignoring() {
  # Run the script
  ./run.sh "$test_dir" -i "docx,c,png"

  # Validate
  local i_files=('document2.docx' 'other1.c' 'image2.png')
  for file in "${i_files[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  if assert_file_exists "${test_dir}/document1.doc"; then
    error_msg="This file shouldn't exist (${test_dir}/document1.doc)."
    return
  fi
}

test_dry_run() {
  # Run the script
  ./run.sh "$test_dir" -n -i "cs,mp4"

  # Validate
  for file in "${images[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${videos[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${documents[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done

  for file in "${others[@]}"; do
    local file_path="${test_dir}/${file}"
    if ! assert_file_exists "$file_path"; then
      error_msg="There is no such file ($file_path)."
      return
    fi
  done
}

# --- Execution ---

declare -A tests
tests[test_basic_organization]='Basic Organization'
tests[test_category_excluding]='Category Excluding'
tests[test_others_dir_excluding]='Others Directory Excluding'
tests[test_extension_ignoring]='Extension Ignoring'
tests[test_dry_run]='Dry Run'

test_number=0
for test in "${!tests[@]}"; do
  ((test_number++))
  error_msg=''

  echo "--- Test $test_number: ${tests[$test]} ---"
  before_each

  $test &>/dev/null

  if [[ -n "$error_msg" ]]; then
    print_failed "$error_msg"
  else
    print_passed
  fi

  after_each
done

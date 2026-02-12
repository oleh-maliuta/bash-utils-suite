#!/bin/bash

# --- Variables ---

error_msg=''

test_dir='./test'

files=(
  "image.JPG"
  "file with spaces.txt"
  "document.pdf"
  "subdir/nested_script.sh"
  "collision_a.txt"
  "collision_b.txt"
)

# --- Helper Functions ---

before_each() {
  # Create the test directory
  mkdir -p "$test_dir/subdir"

  # Create dummy files
  for file in "${files[@]}"; do
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

test_prefix_and_suffix() {
  ./run.sh -d "$test_dir" -p 'vacation_' -s '_v1'

  if ! assert_file_exists "${test_dir}/vacation_image_v1.JPG"; then
    error_msg="There is no such file (${test_dir}/vacation_image_v1.JPG)."
    return
  fi

  if ! assert_file_exists "${test_dir}/vacation_file with spaces_v1.txt"; then
    error_msg="There is no such file (${test_dir}/vacation_file with spaces_v1.txt)."
    return
  fi

  if ! assert_file_exists "${test_dir}/subdir/nested_script.sh"; then
    error_msg="There is no such file (${test_dir}/subdir/nested_script.sh)."
    return
  fi
}

test_recursive_and_uppercase() {
  ./run.sh -d "$test_dir" -r --upper

  if ! assert_file_exists "${test_dir}/IMAGE.JPG"; then
    error_msg="There is no such file (${test_dir}/IMAGE.JPG)."
    return
  fi

  if assert_file_exists "${test_dir}/image.JPG"; then
    error_msg="This file shouldn't exist (${test_dir}/image.JPG)."
    return
  fi

  if ! assert_file_exists "${test_dir}/subdir/NESTED_SCRIPT.sh"; then
    error_msg="There is no such file (${test_dir}/subdir/NESTED_SCRIPT.sh)."
    return
  fi
}

test_search_and_replace() {
  ./run.sh -d "$test_dir" --find ' ' --with '_'

  if ! assert_file_exists "${test_dir}/file_with_spaces.txt"; then
    error_msg="There is no such file (${test_dir}/file_with_spaces.txt)."
    return
  fi

  if assert_file_exists "${test_dir}/file with spaces.txt"; then
    error_msg="This file shouldn't exist (${test_dir}/file with spaces.txt)."
    return
  fi
}

test_collision_avoidance() {
  ./run.sh -d "$test_dir" --find 'collision_a' --with 'collision_b'

  if ! assert_file_exists "${test_dir}/collision_a.txt"; then
    error_msg="There is no such file (${test_dir}/collision_a.txt)."
    return
  fi

  if ! assert_file_exists "${test_dir}/collision_b.txt"; then
    error_msg="There is no such file (${test_dir}/collision_b.txt)."
    return
  fi
}

test_dry_run() {
  ./run.sh -d "$test_dir" -n -p 'FAIL_'

  if ! assert_file_exists "${test_dir}/image.JPG"; then
    error_msg="There is no such file (${test_dir}/image.JPG)."
    return
  fi

  if assert_file_exists "${test_dir}/FAIL_image.JPG"; then
    error_msg="This file shouldn't exist (${test_dir}/FAIL_image.JPG)."
    return
  fi
}

# --- Execution ---

declare -A tests
tests[test_prefix_and_suffix]='Prefix and Suffix'
tests[test_recursive_and_uppercase]='Recursive and Uppercase'
tests[test_search_and_replace]='Search and Replace'
tests[test_collision_avoidance]='Collision Avoidance'
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

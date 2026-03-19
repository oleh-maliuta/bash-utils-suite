#!/bin/bash

# --- Variables ---

dry_run=false
target_dir=''
trash_dir='./duplicate_trash'
log_file='./duplicate_file_finder_logging.txt'
remove_duplicates=false

#  --- Functions ---

# Print Usage Helper
usage() {
  echo "Usage: $0 <directory_path> [OPTIONS]"
  echo
  echo "Options:"
  echo "  -t, --trash-dir   Directory to put the duplicates in (default: ./duplicate_trash)."
  echo "  -r, --remove      Remove found duplicates."
  echo "  -l, --log         Create a .txt file to log the duplicates."
  echo "  -n, --dry-run     Simulate file renaming."
  echo "  -h, --help        Show this help message."
  echo
  echo "Examples:"
  echo "  $0 --trash-dir './trash' --dry-run"
  echo "  $0 --remove --log"
}

# --- Argument Parsing ---

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -t | --trash-dir)
    trash_dir="$2"
    shift 2
    ;;
  -r | --remove)
    remove_duplicates=true
    shift
    ;;
  -n | --dry-run)
    dry_run=true
    shift
    ;;
  -l | --log)
    log_file="$2"
    shift 2
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    # Assume it's the directory path if it's not a flag
    if [[ -z "$target_dir" && ! "$key" =~ ^- ]]; then
      target_dir="$key"
      shift
    else
      echo "Error: Unknown option or multiple directories provided: $1"
      usage
      exit 1
    fi
    ;;
  esac
done

# --- Validation ---

# Fallback to current directory if no target was provided
if [[ -z "$target_dir" ]]; then
  target_dir='.'
fi

# Check if directory exists
if [[ ! -d "$target_dir" ]]; then
  echo "Error: Target Directory '$target_dir' does not exist."
  exit 1
fi

# Check if trash_dir doesn't exist or is empty
if [[ -d "$trash_dir" && -n "$(ls -A "$trash_dir")" ]]; then
  echo "Error: Trash Directory '$trash_dir' exists and is not empty."
  exit 1
fi

# Create the log file
if ! echo 'Duplicate File Finder - Log' >"$log_file"; then
  echo "Error: Log File '$log_file' couldn't be created."
  exit 1
fi

# Write current operation mode into the log file
if [[ "$dry_run" == true ]]; then
  echo "Dry Run (emulate)." >>"$log_file"
elif [[ "$remove_duplicates" == true ]]; then
  echo "Deleting the duplicates permanently." >>"$log_file"
else
  echo "Moving duplicates to ${trash_dir}." >>"$log_file"
fi

# Remove trailing slash from target_dir and trash_dir if present
target_dir="${target_dir%/}"
trash_dir="${trash_dir%/}"

# --- Main Logic ---

declare -A files_by_size

while IFS= read -r -d '' file; do
  if [[ "$OSTYPE" == "darwin"* ]]; then
    size=$(stat -f %z "$file")
  else
    size=$(stat -c %s "$file")
  fi

  if [[ "$size" -gt 0 ]]; then
    files_by_size["$size"]+="$file::"
  fi
done < <(find "$target_dir" -maxdepth 1 -type f -print0)

declare -A files_by_hash

for size in ${!files_by_size[@]}; do
  IFS='::' read -r -a file_group <<<"${files_by_size[$size]}"

  if [[ ${#file_group[@]} -gt 1 ]]; then
    for file in "${file_group[@]}"; do
      if [[ -f "$file" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
          hash=$(md5 -q "$file")
        else
          hash=$(md5sum "$file" | awk '{print $1}')
        fi
        files_by_hash["$hash"]+="$file::"
      fi
    done
  fi
done

unset files_by_size

found_dupes=0

for hash in "${!files_by_hash[@]}"; do
  IFS='::' read -r -a dupe_group <<<"${files_by_hash[$hash]}"

  valid_count=0
  for f in "${dupe_group[@]}"; do
    if [[ -f "$f" ]]; then
      ((valid_count++))
    fi
  done

  if [[ $valid_count -gt 1 ]]; then
    echo -e "\nDUPLICATE SET FOUND:"

    original_file=""
    original_time=0

    for f in "${dupe_group[@]}"; do
      if [[ -f "$f" ]]; then
        f_time=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f")
        if [[ -z "$original_file" ]] || [[ $f_time -lt $original_time ]]; then
          original_file="$f"
          original_time=$f_time
        fi
      fi
    done

    echo "   ORIGINAL (Oldest): $original_file"

    for file in "${dupe_group[@]}"; do
      if [[ -f "$file" && "$file" != "$original_file" ]]; then
        ((found_dupes++))
        echo "      - $file"

        if [[ "$dry_run" == false ]]; then
          if [[ "$remove_duplicates" == true ]]; then
            rm "$file"
            echo "$(date): '$file'" >>"$log_file"
          else
            mkdir -p "$trash_dir"
            mv "$file" "$trash_dir/"
            echo "$(date): '$file' to '$trash_dir'" >>"$log_file"
          fi
        else
          echo "$(date): '$file'" >>"$log_file"
        fi
      fi
    done
  fi
done

# Summary
echo '=== Processing complete ==='
if [[ $found_dupes -eq 0 ]]; then
  echo 'No duplicates found!'
else
  echo "Done. Check $log_file for history."
fi
#!/bin/bash

# --- Variables ---

dry_run=false
target_dir='.'
recursive=false
prefix=''
suffix=''
search_str=''
replace_str=''
to_lower=false
to_upper=false
add_date=false

#  --- Functions ---

# Print Usage Helper
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -d, --dir         Directory to process (default: current dir)."
  echo "  -r, --recursive   Include subdirectories."
  echo "  -p, --prefix      Add text to the beginning of the filename."
  echo "  -s, --suffix      Add text to the end (before extension)."
  echo "  -f, --find        String or Regex pattern to find."
  echo "  -w, --with        String to replace with."
  echo "  --lower           Convert filenames to lowercase."
  echo "  --upper           Convert filenames to uppercase."
  echo "  --date            Prepend current date (YYYY-MM-DD_)."
  echo "  -v, --verbose     Show detailed output."
  echo "  -n, --dry-run     Simulate file renaming."
  echo "  -h, --help        Show this help message."
  echo
  echo "Examples:"
  echo "  $0 --find 'IMG' --with 'Vacation' --dry-run"
  echo "  $0 --dir ./photos --prefix '2023_' --lower"
}

# Logger
log() {
  if $verbose || $dry_run; then
    echo "$1"
  fi
}

# Action wrapper to handle dry runs
run_cmd() {
  local msg="$1"
  local cmd="$2"

  if $dry_run; then
    echo "[DRY RUN] $msg"
  else
    log "$msg"
    eval "$cmd"
  fi
}

# --- Argument Parsing ---

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--dir) target_dir="$2"; shift 2 ;;
    -r|--recursive) recursive=true; shift ;;
    -p|--prefix) prefix="$2"; shift 2 ;;
    -s|--suffix) suffix="$2"; shift 2 ;;
    -f|--find) search_str="$2"; shift 2 ;;
    -w|--with) replace_str="$2"; shift 2 ;;
    --lower) to_lower=true; shift ;;
    --upper) to_upper=true; shift ;;
    --date) add_date=true; shift ;;
    -n|--dry-run) dry_run=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# --- Validation ---

# Check if directory exists
if [[ ! -d "$target_dir" ]]; then
  echo "Error: Directory '$target_dir' does not exist."
  exit 1
fi

# Remove trailing slash from tagret_dir if present
target_dir="${target_dir%/}"

# --- Main Logic ---

# Determine 'find' depth
max_depth=""
if ! $recursive; then
    max_depth="-maxdepth 1"
fi

# Statistics
count_total=0
count_changed=0

find "$target_dir" $max_depth -type f -not -name "undo_rename_*.sh" -not -name "$(basename $0)" -print0 | while IFS= read -r -d '' file_path; do
  dir_name=$(dirname "$file_path")
  base_name=$(basename "$file_path")

  # Split extension
  if [[ "$base_name" == *.* ]]; then
    extension="${base_name##*.}"
    filename="${base_name%.*}"
    dot_ext=".$extension"
  else
    filename="$base_name"
    dot_ext=""
    extension=""
  fi

  original_filename="$filename"

  # Apply Search and Replace
  if [[ -n "$search_str" ]]; then
    filename=$(echo "$filename" | sed "s/$search_str/$replace_str/g")
  fi

  # Case Conversion
  if $to_lower; then
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
  elif $to_upper; then
    filename=$(echo "$filename" | tr '[:lower:]' '[:upper:]')
  fi

  # Add Date
  if $add_date; then
    date_prefix=$(date + "%Y-%m-%d_")
    filename="${date_prefix}${filename}"
  fi

  # Add Prefix and Suffix
  filename="${prefix}${filename}${suffix}"

  # Reassemble new full name
  new_base_name="${filename}${dot_ext}"
  new_full_path="${dir_name}/${new_base_name}"

  # Only proceed if the name actually changed
  if [[ "$base_name" != "$new_base_name" ]]; then
    ((count_changed++))

    if [[ -e "$new_full_path" ]]; then
      echo "[FAILURE] Cannot rename '${base_name}' -> '${new_base_name}'. File exists. Skipping."
      continue
    fi

    if $dry_run; then
      echo "[PREVIEW] ${base_name} --> ${new_base_name}"
    else
      mv "$file_path" "$new_full_path"
      echo "[OK] Renamed: ${base_name} -> ${new_base_name}"
    fi
  fi

  ((count_total++))
done

# Summary
echo '=== Renaming complete ==='

if $dry_run; then
    echo "Analysis complete. $count_changed files would be renamed (out of $count_total scanned)."
else
    echo "Job complete. $count_changed files renamed."
fi

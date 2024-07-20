#!/bin/bash

# Get the list of docker-volumes-backup_ files sorted by the date in the filename (newest first)
files=( $(ls docker-volumes-backup_* | sort -t_ -k2 -r) )

# Check if there are more than 3 backup files
if [ ${#files[@]} -gt 3 ]; then
  # Get the backup files to delete (all except the newest 3)
  files_to_delete=( "${files[@]:3}" )

  # Delete the old backup files
  for file in "${files_to_delete[@]}"; do
    echo "Deleting old backup file: $file"
    rm "$file"
  done
else
  echo "There are 3 or fewer docker-volumes-backup_ files. No files to delete."
fi

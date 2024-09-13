#!/bin/bash

# Directory to scan (modify as needed)
directory="/your/folder/path"
TARGET_DIR="/path/to/folder"  # Directory where tgz files will be extracted

# Display options for the user
echo "Please choose an option to process files:"
echo "1) Extract Google Backup tgz files"
echo "2) Rename files based on actual file type"
echo "3) Handle files with associated JSON metadata"
echo "4) VID-YYYYMMDD-WA####.mp4 (e.g., VID-20240906-WA0001.mp4)"
echo "5) IMG-YYYYMMDD-WA####.jpg (e.g., IMG-20240906-WA0001.jpg)"
echo "6) IMG_YYYYMMDD_HHMMSS_XXX.jpg (e.g., IMG_20240216_124644_660.jpg)"
echo "7) YYYYMMDD_HHMMSS.jpg (e.g., 20240216_124644.jpg)"
echo "8) Screenshot_YYYYMMDD_HHMMSS_WhatsApp.jpg (e.g., Screenshot_20230104_112332_WhatsApp.jpg)"
echo "9) All"
read -p "Enter your choice (1-9): " choice

# Process the user's choice
case $choice in
    1)
        # Extract Google Backup tgz files
        echo "Extracting Google Backup tgz files..."
        for file in takeout-*-*.tgz; do
            if [[ -f "$file" ]]; then
                echo "Extracting $file..."
                if tar -xzf "$file" -C "$TARGET_DIR"; then
                    echo "$file extracted successfully and moved to $TARGET_DIR"
                    # If successfully extracted then delete tgz files
                    rm "$file"
                    echo "$file deleted."
                else
                    echo "Error: Occurred while extracting $file."
                fi
            fi
        done
        echo "All files extracted."
        exit 0
        ;;
    2)
        # Rename files based on actual file type
        find "$directory" -type f | while read -r file; do
            # Get the actual file type using exiftool
            file_type=$(exiftool -FileType -b "$file")

            # Get the file extension
            current_extension="${file##*.}"
            current_extension=$(echo "$current_extension" | tr '[:upper:]' '[:lower:]')

            # Expected extension based on file type
            case "$file_type" in
                JPEG) expected_extension="jpg" ;;
                HEIC) expected_extension="heic" ;;
                MOV)  expected_extension="mov" ;;
                MP4)  expected_extension="mp4" ;;
                PNG)  expected_extension="png" ;;
                *)    expected_extension="$current_extension" ;; # Default to current extension if unknown
            esac

            # Check if the current extension matches the expected extension
            if [[ "$current_extension" != "$expected_extension" ]]; then
                # Construct the new file name with the correct extension
                new_file="${file%.*}.$expected_extension"
                
                # Rename the file
                echo "Renaming '$file' to '$new_file'"
                mv "$file" "$new_file"
            else
                echo "File '$file' already has the correct extension"
            fi
        done
        exit 0
        ;;
    3)
        # Handle files with associated JSON metadata
        find "$directory" -type f ! -name '*.json' | while read -r file; do
            # Construct the corresponding JSON file path
            jsonfile="${file}.json"

            # Check if the JSON file exists
            if [ -f "$jsonfile" ]; then
                # Check if the file already has a CreateDate or DateTimeOriginal
                create_date_check=$(exiftool -CreateDate "$file" | grep -c 'Create Date')
                datetime_original_check=$(exiftool -DateTimeOriginal "$file" | grep -c 'Date Time Original')

                # Process only if CreateDate or DateTimeOriginal is not set
                if [ "$create_date_check" -eq 0 ] && [ "$datetime_original_check" -eq 0 ]; then
                    # Extract the timestamp from the JSON file
                    timestamp=$(jq -r '.creationTime.timestamp' "$jsonfile")

                    # Convert the timestamp to the desired format
                    create_date=$(date -d @"$timestamp" "+%Y:%m:%d %H:%M:%S")

                    # Set the CreateDate and FileModifyDate in the file
                    exiftool "-CreateDate=$create_date" "-FileModifyDate=$create_date" \
                        -overwrite_original_in_place "$file"

                    echo "Updated metadata for $file"
                else
                    echo "CreateDate or DateTimeOriginal already set for $file, skipping."
                fi
            else
                echo "No JSON file found for $file"
            fi
        done
        exit 0
        ;;
    4)  condition='$Filename =~ /^VID-\d{8}-WA/' ;;
    5)  condition='$Filename =~ /^IMG-\d{8}-WA/' ;;
    6)  condition='$Filename =~ /^IMG_\d{8}_\d{6}_\d{3}/' ;;
    7)  condition='$Filename =~ /^\d{8}_\d{6}/' ;;
    8)  condition='$Filename =~ /^Screenshot_\d{8}_\d{6}_WhatsApp/' ;;
    9)  condition='$Filename =~ /^VID-\d{8}-WA/ or $Filename =~ /^IMG-\d{8}-WA/ or $Filename =~ /^IMG_\d{8}_\d{6}_\d{3}/ or $Filename =~ /^\d{8}_\d{6}/ or $Filename =~ /^Screenshot_\d{8}_\d{6}_WhatsApp/' ;;
    *)  echo "Invalid choice"; exit 1 ;;
esac

# Run exiftool with the chosen condition and fallback if CreateDate is not present
exiftool -if "($condition)" \
'-CreateDate<${Filename;
    if (/^VID-/ or /^IMG-/) {
        $_ = substr($_, 4, 8) =~ s/(....)(..)(..)/$1:$2:$3 00:00:00/r 
    } elsif (/^\d{8}_/) {
        $_ = substr($_, 0, 8) =~ s/(....)(..)(..)/$1:$2:$3 12:00:00/r 
    } elsif (/^Screenshot_\d{8}_\d{6}_WhatsApp/) {
        $_ = substr($_, 11, 8) =~ s/(....)(..)(..)/$1:$2:$3 12:00:00/r 
    }
}' '-FileModifyDate<${CreateDate//DateTimeOriginal//ModifyDate}' \
-ext mp4 -ext jpg -ext heic -overwrite_original_in_place -r "$directory"

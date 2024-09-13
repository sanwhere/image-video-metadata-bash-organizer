# File Processing Script

## Overview

This script is designed to automate the process of managing files, especially those related to media backups such as photos, videos, and Google Takeout files. It provides several options for handling files, including extracting `.tgz` backup files, renaming files based on actual file types, processing files with metadata stored in JSON files, and updating file metadata using file naming conventions.

## Features

1. **Extract Google Backup `.tgz` Files**
2. **Rename Files Based on Actual File Type**
3. **Handle Files with Associated JSON Metadata**
4. **Process Files Based on Naming Conventions** 
    - `VID-YYYYMMDD-WA####.mp4`
    - `IMG-YYYYMMDD-WA####.jpg`
    - `IMG_YYYYMMDD_HHMMSS_XXX.jpg`
    - `YYYYMMDD_HHMMSS.jpg`
    - `Screenshot_YYYYMMDD_HHMMSS_WhatsApp.jpg`
5. **Batch Processing**

---

## How to Use

### 1. **Clone or download the script.**
```
git clone https://your-repository-url
```

### 2. **Make the script executable.**
```
chmod +x your-script.sh
```

### 3. **Run the script.**
```
./your-script.sh
```

---

## Script Options Explained

When running the script, you will be prompted to select an option from a list. Each option performs a specific task:

### 1. **Extract Google Backup `.tgz` Files**
This option scans the current directory for Google Takeout `.tgz` files (such as `takeout-*-*.tgz`) and extracts them to a specified target directory. After successful extraction, the original `.tgz` files are deleted.

### 2. **Rename Files Based on Actual File Type**
This option identifies the file format of media files and renames them with the correct extension (e.g., `.jpg`, `.mp4`, `.heic`). The script will detect files mislabeled with incorrect extensions and rename them accordingly.

For example:
- If a file is mislabeled as `.jpg` but is actually a video (`.mp4`), it will be renamed to `filename.mp4`.
- This prevents files from being treated incorrectly by other software.

### 3. **Handle Files with Associated JSON Metadata**
This option handles files that have associated `.json` files. Some media files (like Google Takeout files) come with metadata stored separately in `.json` files. The script checks if a corresponding `.json` file exists for each media file. If the media file is missing the `CreateDate` or `DateTimeOriginal` metadata, it extracts the creation timestamp from the `.json` file and applies it to the media file.

Example:
- `IMG_20240906.jpg` might have a `IMG_20240906.jpg.json` file, and the script will ensure that the `CreateDate` and `FileModifyDate` fields are updated in the image metadata.

### 4. **Process Files Based on Naming Conventions**
This option processes files based on certain naming conventions that include a date and/or time in the filename. The script extracts the date from the filename and uses it to populate the `CreateDate` and `FileModifyDate` fields in the file’s metadata.

Here are the file naming conventions supported:

#### a. `VID-YYYYMMDD-WA####.mp4`
Files that follow the pattern `VID-YYYYMMDD-WA####.mp4` are video files, typically from WhatsApp or other messaging platforms. The script will extract the date from the filename and update the `CreateDate` metadata accordingly.

Example: 
- `VID-20240906-WA0001.mp4` will have the date `2024:09:06 00:00:00` applied to the `CreateDate` field.

#### b. `IMG-YYYYMMDD-WA####.jpg`
Similar to the video files, image files with the pattern `IMG-YYYYMMDD-WA####.jpg` will have their dates extracted from the filename.

Example: 
- `IMG-20240906-WA0001.jpg` will have the date `2024:09:06 00:00:00` applied to the `CreateDate` field.

#### c. `IMG_YYYYMMDD_HHMMSS_XXX.jpg`
This pattern is used for images that include both the date and time in the filename.

Example: 
- `IMG_20240216_124644_660.jpg` will have the date `2024:02:16 12:46:44` applied to the `CreateDate` field.

#### d. `YYYYMMDD_HHMMSS.jpg`
Files that follow the pattern `YYYYMMDD_HHMMSS.jpg` are handled similarly, with the date and time being extracted from the filename and applied to the metadata.

Example: 
- `20240216_124644.jpg` will have the date `2024:02:16 12:46:44` applied to the `CreateDate` field.

#### e. `Screenshot_YYYYMMDD_HHMMSS_WhatsApp.jpg`
This pattern is typically used for screenshots saved from WhatsApp. The script will extract the date and time from the filename and update the metadata accordingly.

Example: 
- `Screenshot_20230104_112332_WhatsApp.jpg` will have the date `2023:01:04 11:23:32` applied to the `CreateDate` field.

### 5. **Batch Processing**
By selecting the "All" option, the script will process all file types and naming conventions mentioned above in one go, applying the appropriate transformations and metadata updates.

--- 

## Conclusion

This script is a versatile tool for handling media files, especially when dealing with large backups from services like Google Takeout. By using naming conventions and metadata stored in `.json` files, the script ensures that your media files have accurate metadata, making them easier to organize and search in the future.


#!/bin/bash

# Function to check if a file or directory exists
check_exists() {
    if [ ! -e "$1" ]; then
        echo "Error: $1 does not exist in the current directory"
        return 1
    fi
    return 0
}

# Check if all required files and folders are present
echo "Checking for required files and folders..."

required_items=(".claude" "convertednotes" "convertedpdf" "pdffiles" "structurednotes" "CLAUDE.md")
all_present=true

for item in "${required_items[@]}"; do
    if ! check_exists "$item"; then
        all_present=false
    fi
done

# If any required item is missing, exit
if [ "$all_present" = false ]; then
    echo "Not all required files and folders are present. Exiting."
    exit 1
fi

echo "All required files and folders are present. Proceeding with cleanup..."

# Copy all markdown files from structurednotes to current directory
echo "Copying markdown files from structurednotes to current directory..."
if [ -d "structurednotes" ]; then
    # Check if there are any .md files in structurednotes
    if ls structurednotes/*.md 1> /dev/null 2>&1; then
        cp structurednotes/*.md .
        echo "Markdown files copied successfully."
    else
        echo "No markdown files found in structurednotes directory."
    fi
else
    echo "Warning: structurednotes directory not found."
fi

# Delete specified folders
echo "Deleting specified folders..."
folders_to_delete=(".git" ".claude" "convertednotes" "convertedpdf" "pdffiles" "structurednotes" "scripts")

for folder in "${folders_to_delete[@]}"; do
    if [ -d "$folder" ]; then
        rm -rf "$folder"
        echo "Deleted folder: $folder"
    else
        echo "Warning: Folder $folder not found."
    fi
done

# Delete specified files
echo "Deleting specified files..."
files_to_delete=("CLAUDE.md" "LICENSE")

for file in "${files_to_delete[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "Deleted file: $file"
    else
        echo "Warning: File $file not found."
    fi
done

echo "Markdown files are successfully cleaned"

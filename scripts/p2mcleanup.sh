#!/bin/bash

# Function to check if a file or directory exists
check_exists() {
    if [ ! -e "$1" ]; then
        echo "Warning: $1 does not exist in the current directory"
        return 1
    fi
    return 0
}

# Check if required files and folders are present
echo "Checking for required files and folders..."
required_items=("pdffiles" "structurednotes" "CLAUDE.md")
items_found=0

for item in "${required_items[@]}"; do
    if check_exists "$item"; then
        ((items_found++))
    fi
done

# If no required items found, exit
if [ $items_found -eq 0 ]; then
    echo "None of the expected files and folders are present. Nothing to clean up."
    exit 1
fi

echo "Found $items_found out of ${#required_items[@]} expected items. Proceeding with cleanup..."

# Copy all markdown files from structurednotes to current directory
echo "Copying markdown files from structurednotes to current directory..."
if [ -d "structurednotes" ]; then
    # Check if there are any .md files in structurednotes
    if ls structurednotes/*.md 1> /dev/null 2>&1; then
        cp structurednotes/*.md .
        echo "✓ Markdown files copied successfully."
    else
        echo "No markdown files found in structurednotes directory."
    fi
else
    echo "structurednotes directory not found. Skipping markdown file copy."
fi

# Delete specified folders (optional - only if they exist)
echo ""
echo "Cleaning up folders..."
folders_to_delete=("convertednotes" "convertedpdf" "pdffiles" "structurednotes")
deleted_count=0

for folder in "${folders_to_delete[@]}"; do
    if [ -d "$folder" ]; then
        rm -rf "$folder"
        echo "✓ Deleted folder: $folder"
        ((deleted_count++))
    fi
done

if [ $deleted_count -eq 0 ]; then
    echo "No folders to delete."
else
    echo "Deleted $deleted_count folder(s)."
fi

# Delete specified files (optional - only if they exist)
echo ""
echo "Cleaning up files..."
files_to_delete=("CLAUDE.md")
deleted_files=0

for file in "${files_to_delete[@]}"; do
    if [ -f "$file" ]; then
        rm "$file"
        echo "✓ Deleted file: $file"
        ((deleted_files++))
    fi
done

if [ $deleted_files -eq 0 ]; then
    echo "No files to delete."
fi

echo ""
echo "✓ Cleanup completed successfully!"
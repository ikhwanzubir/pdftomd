#!/bin/bash

# macOS Compatible Cleanup Script
# Compatible with macOS Monterey, Ventura, Sonoma, and Sequoia

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Function to check if a file or directory exists
check_exists() {
    if [[ ! -e "$1" ]]; then
        echo "Error: $1 does not exist in the current directory"
        return 1
    fi
    return 0
}

# Function to safely remove files/directories
safe_remove() {
    local target="$1"
    local type="$2"
    
    if [[ "$type" == "file" && -f "$target" ]]; then
        rm "$target" && echo "Deleted file: $target"
    elif [[ "$type" == "directory" && -d "$target" ]]; then
        rm -rf "$target" && echo "Deleted folder: $target"
    else
        echo "Warning: $type $target not found."
    fi
}

# Main execution
main() {
    echo "macOS Cleanup Script - Starting..."
    
    # Check if all required files and folders are present
    echo "Checking for required files and folders..."
    local required_items=(".claude" "convertednotes" "convertedpdf" "pdffiles" "structurednotes" "CLAUDE.md")
    local all_present=true
    
    for item in "${required_items[@]}"; do
        if ! check_exists "$item"; then
            all_present=false
        fi
    done
    
    # If any required item is missing, exit
    if [[ "$all_present" == "false" ]]; then
        echo "Not all required files and folders are present. Exiting."
        exit 1
    fi
    
    echo "All required files and folders are present. Proceeding with cleanup..."
    
    # Copy all markdown files from structurednotes to current directory
    echo "Copying markdown files from structurednotes to current directory..."
    if [[ -d "structurednotes" ]]; then
        # Use find for more reliable file detection (works better on all macOS versions)
        local md_files
        md_files=$(find structurednotes -maxdepth 1 -name "*.md" -type f 2>/dev/null || true)
        
        if [[ -n "$md_files" ]]; then
            # Use while loop to handle filenames with spaces properly
            find structurednotes -maxdepth 1 -name "*.md" -type f -print0 | while IFS= read -r -d '' file; do
                cp "$file" .
            done
            echo "Markdown files copied successfully."
        else
            echo "No markdown files found in structurednotes directory."
        fi
    else
        echo "Warning: structurednotes directory not found."
    fi
    
    # Delete specified folders
    echo "Deleting specified folders..."
    local folders_to_delete=(".git" ".claude" "convertednotes" "convertedpdf" "pdffiles" "structurednotes" "scripts")
    
    for folder in "${folders_to_delete[@]}"; do
        safe_remove "$folder" "directory"
    done
    
    # Delete specified files  
    echo "Deleting specified files..."
    local files_to_delete=("CLAUDE.md" "LICENSE")
    
    for file in "${files_to_delete[@]}"; do
        safe_remove "$file" "file"
    done
    
    echo "✅ Markdown files cleanup completed successfully!"
}

# Run main function
main "$@"
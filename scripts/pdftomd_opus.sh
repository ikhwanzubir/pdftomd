#!/bin/bash

# Function to display error messages
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Function to display success messages
success_msg() {
    echo "✓ $1"
}

echo "Checking current directory for required files..."

# Check for PDF file with 'new_' prefix (case-insensitive extension)
new_pdf_files=()
for file in new_*; do
    if [ -f "$file" ] && [[ "${file,,}" == *.pdf ]]; then
        new_pdf_files+=("$file")
    fi
done

if [ ${#new_pdf_files[@]} -eq 0 ]; then
    error_exit "Current directory must contain at least one PDF file with 'new_' prefix"
fi

# If multiple PDF files, process the oldest one first
if [ ${#new_pdf_files[@]} -gt 1 ]; then
    echo "Found multiple PDF files with 'new_' prefix. Processing the oldest file first..."
    oldest_file=""
    oldest_time=0
    
    for file in "${new_pdf_files[@]}"; do
        file_time=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
        if [ -z "$oldest_file" ] || [ "$file_time" -lt "$oldest_time" ]; then
            oldest_file="$file"
            oldest_time="$file_time"
        fi
    done
    
    pdf_file="$oldest_file"
else
    pdf_file="${new_pdf_files[0]}"
fi

success_msg "Found PDF file with 'new_' prefix: $pdf_file"

# Create a new folder with the PDF file name without the 'new_' prefix
folder_name="${pdf_file#new_}"  # Remove 'new_' prefix from PDF filename
folder_name="${folder_name%.pdf}"  # Remove .pdf extension to get folder name

# Replace whitespaces with underscores in folder name
folder_name="${folder_name// /_}"

mkdir "$folder_name" || error_exit "Failed to create folder: $folder_name"
success_msg "Created folder: $folder_name"

# Store original directory
original_dir=$(pwd)

echo ""
echo "Starting setup process..."

# Step 2a: Change directory into the created folder
cd "$folder_name" || error_exit "Failed to change directory to $folder_name"
success_msg "Changed directory to $folder_name"

# Step 2b: Download CLAUDE.md file
echo "Downloading CLAUDE.md file..."
if curl -sSL -o CLAUDE.md https://raw.githubusercontent.com/ikhwanzubir/pdftomd/refs/heads/main/CLAUDE.md; then
    success_msg "Successfully downloaded CLAUDE.md"
else
    error_exit "Failed to download CLAUDE.md. Make sure curl is installed and you have internet connection"
fi

# Step 2b-extra: Create required subfolders
echo "Creating required subfolders..."
mkdir -p pdffiles || error_exit "Failed to create pdffiles folder"
success_msg "Created pdffiles folder"

mkdir -p convertednotes || error_exit "Failed to create convertednotes folder"
success_msg "Created convertednotes folder"

mkdir -p convertedpdf || error_exit "Failed to create convertedpdf folder"
success_msg "Created convertedpdf folder"

mkdir -p structurednotes || error_exit "Failed to create structurednotes folder"
success_msg "Created structurednotes folder"

# Step 2c: Move the PDF file into the folder
cd "$original_dir" || error_exit "Failed to return to original directory"
mv "$pdf_file" "$folder_name/" || error_exit "Failed to move PDF file"
success_msg "Moved PDF file into $folder_name"

# Step 2d: Remove 'new_' prefix from PDF file and replace whitespaces with underscores
cd "$folder_name" || error_exit "Failed to change to folder"
if [[ "$pdf_file" == new_* ]]; then
    final_pdf_name="${pdf_file#new_}"
    # Replace whitespaces with underscores in PDF filename
    final_pdf_name="${final_pdf_name// /_}"
    mv "$pdf_file" "$final_pdf_name" || error_exit "Failed to rename PDF file"
    success_msg "Renamed PDF file from '$pdf_file' to '$final_pdf_name'"
else
    # Even if no 'new_' prefix, still replace whitespaces with underscores
    final_pdf_name="${pdf_file// /_}"
    if [[ "$pdf_file" != "$final_pdf_name" ]]; then
        mv "$pdf_file" "$final_pdf_name" || error_exit "Failed to rename PDF file"
        success_msg "Renamed PDF file from '$pdf_file' to '$final_pdf_name' (replaced whitespaces)"
    else
        success_msg "PDF file doesn't need renaming: $pdf_file"
    fi
fi

echo ""
echo "Setup complete! Now starting Claude..."
echo "Running: claude --dangerously-skip-permissions"
echo ""

# Step 2e: Run claude with custom flag
exec claude --model opus --dangerously-skip-permissions
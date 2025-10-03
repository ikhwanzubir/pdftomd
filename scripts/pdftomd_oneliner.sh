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

echo "Scanning directory for PDF files..."
echo ""

# Find all PDF files in current directory
pdf_files=()
for file in *.pdf; do
    if [ -f "$file" ]; then
        pdf_files+=("$file")
    fi
done

# Check if any PDF files were found
if [ ${#pdf_files[@]} -eq 0 ]; then
    error_exit "No PDF files found in current directory"
fi

# Display PDF files with numbers
echo "Found ${#pdf_files[@]} PDF file(s):"
echo ""
for i in "${!pdf_files[@]}"; do
    echo "[$((i+1))] ${pdf_files[$i]}"
done
echo ""

# Get user selection
while true; do
    read -p "Select a PDF file (enter number): " selection
    
    # Validate input is a number
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a number."
        continue
    fi
    
    # Convert to array index (0-based)
    index=$((selection - 1))
    
    # Check if selection is in valid range
    if [ "$index" -ge 0 ] && [ "$index" -lt "${#pdf_files[@]}" ]; then
        selected_pdf="${pdf_files[$index]}"
        break
    else
        echo "Invalid selection. Please enter a number between 1 and ${#pdf_files[@]}."
    fi
done

echo ""
success_msg "Selected: $selected_pdf"

# Create folder name from PDF filename (without .pdf extension)
folder_name="${selected_pdf%.pdf}"
# Replace whitespaces with underscores in folder name
folder_name="${folder_name// /_}"

mkdir "$folder_name" || error_exit "Failed to create folder: $folder_name"
success_msg "Created folder: $folder_name"

# Store original directory
original_dir=$(pwd)

echo ""
echo "Starting setup process..."

# Change directory into the created folder
cd "$folder_name" || error_exit "Failed to change directory to $folder_name"
success_msg "Changed directory to $folder_name"

# Download CLAUDE.md file
echo "Downloading CLAUDE.md file..."
if curl -sSL -o CLAUDE.md https://raw.githubusercontent.com/ikhwanzubir/pdftomd/refs/heads/main/CLAUDE.md; then
    success_msg "Successfully downloaded CLAUDE.md"
else
    error_exit "Failed to download CLAUDE.md. Make sure curl is installed and you have internet connection"
fi

# Create required subfolders
echo "Creating required subfolders..."
mkdir -p pdffiles || error_exit "Failed to create pdffiles folder"
success_msg "Created pdffiles folder"

mkdir -p structurednotes || error_exit "Failed to create structurednotes folder"
success_msg "Created structurednotes folder"

# Move the PDF file into the folder
cd "$original_dir" || error_exit "Failed to return to original directory"
mv "$selected_pdf" "$folder_name/" || error_exit "Failed to move PDF file"
success_msg "Moved PDF file into $folder_name"

# Rename PDF file to replace whitespaces with underscores
cd "$folder_name" || error_exit "Failed to change to folder"
final_pdf_name="${selected_pdf// /_}"
if [[ "$selected_pdf" != "$final_pdf_name" ]]; then
    mv "$selected_pdf" "$final_pdf_name" || error_exit "Failed to rename PDF file"
    success_msg "Renamed PDF file from '$selected_pdf' to '$final_pdf_name'"
else
    success_msg "PDF filename: $final_pdf_name"
fi

echo ""
echo "Setup complete! Now starting Claude Code..."
echo "Running PDF to Markdown Converter"
echo ""

# Run claude code with timeout (10 minutes = 600 seconds)
timeout 600 claude -p --dangerously-skip-permissions "oneliner"

# Check exit status
exit_code=$?
echo ""
if [ $exit_code -eq 124 ]; then
    echo "⚠ Claude Code process timed out after 10 minutes"
elif [ $exit_code -eq 0 ]; then
    success_msg "Claude Code process completed successfully"
else
    echo "⚠ Claude Code process exited with code: $exit_code"
fi

echo ""
echo "Process finished. Running cleanup script..."
echo ""

# Run the cleanup script
if [ -f ~/Scripts/p2mcleanup.sh ]; then
    bash ~/Scripts/p2mcleanup.sh
    if [ $? -eq 0 ]; then
        success_msg "Cleanup completed successfully"
    else
        echo "⚠ Cleanup script encountered an error"
    fi
else
    echo "⚠ Cleanup script not found at ~/Scripts/p2mcleanup.sh"
fi

echo ""
echo "All operations complete. Happy reading!"
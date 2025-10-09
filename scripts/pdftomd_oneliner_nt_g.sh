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

# Function to scan for PDF files (case-insensitive)
scan_pdf_files() {
    pdf_files=()
    for file in *; do
        if [ -f "$file" ]; then
            # Convert filename to lowercase for comparison
            lowercase_file="${file,,}"
            if [[ "$lowercase_file" == *.pdf ]]; then
                pdf_files+=("$file")
            fi
        fi
    done
}

# Function to format seconds into HH:MM:SS
format_time() {
    local seconds=$1
    printf "%02d:%02d:%02d" $((seconds/3600)) $((seconds%3600/60)) $((seconds%60))
}

# Function to create unique folder name
create_unique_folder_name() {
    local base_name="$1"
    local folder_name="$base_name"
    local counter=1
    
    # Check if folder exists, if so, append counter
    while [ -d "$folder_name" ]; do
        folder_name="${base_name}_${counter}"
        ((counter++))
    done
    
    echo "$folder_name"
}

# Main loop for PDF selection
while true; do
    echo "Scanning directory for PDF files..."
    echo ""

    # Scan for PDF files
    scan_pdf_files

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
    echo "[R] Reload/Refresh PDF list"
    echo "[E] Exit"
    echo ""

    # Get user selection
    while true; do
        read -p "Select a PDF file (enter number, R to reload, or E to exit): " selection
        
        # Check for special commands
        if [[ "$selection" =~ ^[Rr]$ ]]; then
            echo ""
            echo "Reloading PDF file list..."
            echo ""
            break  # Break inner loop to rescan
        elif [[ "$selection" =~ ^[Ee]$ ]]; then
            echo ""
            echo "Exiting script. Goodbye!"
            exit 0
        fi
        
        # Validate input is a number
        if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
            echo "Invalid input. Please enter a number, R, or E."
            continue
        fi
        
        # Convert to array index (0-based)
        index=$((selection - 1))
        
        # Check if selection is in valid range
        if [ "$index" -ge 0 ] && [ "$index" -lt "${#pdf_files[@]}" ]; then
            selected_pdf="${pdf_files[$index]}"
            break 2  # Break both loops - valid selection made
        else
            echo "Invalid selection. Please enter a number between 1 and ${#pdf_files[@]}."
        fi
    done
done

echo ""
success_msg "Selected: $selected_pdf"

# Create folder name from PDF filename (without .pdf extension)
base_folder_name="${selected_pdf%.pdf}"
base_folder_name="${base_folder_name%.PDF}"
# Replace whitespaces with underscores in folder name
base_folder_name="${base_folder_name// /_}"

# Get unique folder name
folder_name=$(create_unique_folder_name "$base_folder_name")

# Check if folder name was modified
if [ "$folder_name" != "$base_folder_name" ]; then
    echo "Note: Folder '$base_folder_name' already exists. Using '$folder_name' instead."
fi

mkdir "$folder_name" || error_exit "Failed to create folder: $folder_name"
success_msg "Created folder: $folder_name"

# Store original directory
original_dir=$(pwd)

echo ""
echo "Starting setup process..."

# Change directory into the created folder
cd "$folder_name" || error_exit "Failed to change directory to $folder_name"
success_msg "Changed directory to $folder_name"

# Download GEMINI.md file
echo "Downloading GEMINI.md file..."
if curl -sSL -o GEMINI.md https://raw.githubusercontent.com/ikhwanzubir/pdftomd/refs/heads/main/GEMINI.md; then
    success_msg "Successfully downloaded GEMINI.md"
else
    error_exit "Failed to download GEMINI.md. Make sure curl is installed and you have internet connection"
fi

# Create required subfolders
echo "Creating required subfolders..."
mkdir -p pdffiles || error_exit "Failed to create pdffiles folder"
success_msg "Created pdffiles folder"

mkdir -p structurednotes || error_exit "Failed to create structurednotes folder"
success_msg "Created structurednotes folder"

mkdir -p convertednotes || error_exit "Failed to create convertednotes folder"
success_msg "Created convertednotes folder"

mkdir -p convertedpdf || error_exit "Failed to create convertedpdf folder"
success_msg "Created convertedpdf folder"

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
echo "Setup complete! Now starting Gemini CLI..."
echo "Running PDF to Markdown Converter"
echo ""

exec gemini "oneliner then after finished, execute script ~/Scripts/p2mcleanup.sh" --yolo --model gemini-2.5-flash
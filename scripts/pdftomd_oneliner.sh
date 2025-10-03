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
folder_name="${selected_pdf%.pdf}"
folder_name="${selected_pdf%.PDF}"
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

# Start the stopwatch in background
{
    elapsed=0
    while kill -0 $$ 2>/dev/null; do
        printf "\rElapsed time: %s" "$(format_time $elapsed)"
        sleep 1
        ((elapsed++))
    done
} &
stopwatch_pid=$!

# Run claude code with timeout (30 minutes = 1800 seconds)
timeout 1800 claude -p --dangerously-skip-permissions "oneliner"

# Check exit status
exit_code=$?

# Stop the stopwatch
kill $stopwatch_pid 2>/dev/null
wait $stopwatch_pid 2>/dev/null

# Get final elapsed time
final_time=$(format_time $elapsed)

echo ""
echo ""
echo "Total processing time: $final_time"
echo ""

if [ $exit_code -eq 124 ]; then
    echo "⚠ Claude Code process timed out after 30 minutes"
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
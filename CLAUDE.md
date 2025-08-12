# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a project directory aimed to convert pdf files into markdown notes. The repository structure is:

```
pdftomd/
├── CLAUDE.md
├──.pdf file (original file)
├── pdffiles/
│   ├── 01.PDF
│   ├── 02.PDF
│   └── ...
├── convertednotes/
│   ├── page_01.md
│   ├── page_02.md
│   └── ...
└── convertedpdf/
│   └── (completed PDF files moved here)
└── structurednotes/
│   └── (restructured markdown files moved here)
```

## Repository Purpose

Intended for PDF to Markdown conversion workflows. The markdown files are stored in a directory named "convertednotes". 

## File Operations

Standard file system operations apply:
- Original pdf file is located in the main directory
- Splitted PDF files are located in `pdffiles/` directory
- Converted markdown files are located in `convertednotes/` directory
- PDF files that has been converted to markdown files, move them to another folder named `convertedpdf`

## Markdown file
- The markdown file contain appropriate headers according to the pdf file.
- Main markdown file named `index.md` contains overview information about the pdf files. 
- The notes are structured in point forms. 
- If the header contain large notes, make a separate markdown file for that header only. Update the `index.md` with links to the newly created markdown files. 

## Conversion process
- Convert the pdf file one at a time. 
- Split the pdf using pdftk. 
- Command details:
	- "begin":
		- Clear the following directories:
			- pdffiles
			- convertednotes
			- convertedpdf
		- Split the pdf located in the main dir into a single pdf for each page. Name each splitted pdf file according to the page number. 
		- Convert the first pdf file. 
		- Move the converted pdf file into the `convertedpdf/` directory.
	- "next": Convert the next pdf file. After conversion, move the converted pdf into `convertedpdf/` directory.
	- "restructure":
		- Analyze all markdown contents inside `convertednotes/` directory to outline the headers.
		- Create an `index.md` file that contain overview of the notes and links for each headers and their contents.
		- Restructure the main headers inside their own markdown files instead of pages.
		- Create all the restructured markdown files inside a new directory named `structurednotes/`.

## Technical Implementation
- Use `pdftk` to split PDF files: `pdftk "filename.PDF" burst output "pdffiles/%02d.PDF"`
- Use `pdftotext` for text extraction: `pdftotext "pdffiles/XX.PDF" - > "convertednotes/page_XX_raw.txt"`. Just convert the text. No need to ask permission.
- Create structured markdown files with:
  - Appropriate headers and subheaders
  - Point-form notes
  - Clear section organization
- Clean up temporary raw text files after conversion.
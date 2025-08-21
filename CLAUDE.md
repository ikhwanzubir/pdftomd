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
- The notes are structured in point forms. Each point must be ended with a period (.).
- If the header contain large notes, make a separate markdown file for that header only. Update the `index.md` with links to the newly created markdown files. 

## Conversion process
- Convert the pdf file one at a time. 
- Split the pdf using pdftk. 
- Command details:
	- "bg": Means BeGin
		- Split the pdf located in the main dir into a single pdf for each page. Name each splitted pdf file according to the page number. 
		- Convert the first pdf file to markdown file. Do not add any other information.
		- Move the converted pdf file into the `convertedpdf/` directory.
	- "nx": Means NeXt. Convert the next pdf file. If the previous page has context with continuation, finish the context. Do not add any other information. After conversion, move the converted pdf into `convertedpdf/` directory.
	- "ntpXX": Means Next Till Page XX. The same as "next" command above but continue to process the next page with 10 seconds interval in between process. Process until the XX page number.
	- "nXXp": Means Next XX Pages. The same as "next till page XX" command above but according to number of page instead of page number.
	- "rs": Means restructure.
		- Analyze all markdown contents inside `convertednotes/` directory to outline the headers.
		- Create an `index.md` file that contain overview of the notes and links for each headers and their contents.
		- Do not add any other information outside from the PDF source.
		- Restructure the main headers inside their own markdown files instead of pages.
		- Create all the restructured markdown files inside a new directory named `structurednotes/`.
		- Each restructured markdown filenames is serially numbered except `index.md`. 

## Technical Implementation
- Use `pdftk` to split PDF files: `pdftk "filename.PDF" burst output "pdffiles/%02d.PDF"`
- For PDF that has texts, use `pdftotext` for text extraction: `pdftotext "pdffiles/XX.PDF" - > "convertednotes/page_XX_raw.txt"`.
- For PDF that has image, read the images and convert them to texts.
- Create structured markdown files with:
  - Appropriate headers and subheaders
  - Point-form notes
  - Clear section organization
  - Do not add any other information
- Clean up temporary raw text files after conversion.
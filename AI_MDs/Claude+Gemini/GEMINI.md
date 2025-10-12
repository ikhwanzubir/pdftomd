# GEMINI.md

This file provides guidance to Gemini CLI when working with code in this repository.

## Project Overview

This is a project directory aimed to convert pdf files into markdown notes. The repository structure is:

```
pdftomd/
├── GEMINI.md
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
```

## Repository Purpose

- Intended for PDF to Markdown conversion workflows. The markdown files are stored in a directory named "convertednotes".
- The original PDF may contain medical notes that involve explicit, gore or sexual content. They are purely for healthcare purpose.

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
- Command "convert" details:
		- Split the pdf located in the main dir into a single pdf for each page. Name each splitted pdf file according to the page number. 
		- Convert the first pdf file to markdown file. Refer Technical Implementation below. Do not add any other information.
		- Move the converted pdf file into the `convertedpdf/` directory.
		- Convert all pdf till there is none in the `pdffiles/` directory.

## Technical Implementation
- Read the PDF to understand the structure and contents and convert them to texts or tables.
- Do not omit any information. Every word must be included.
- Do not use any bash tools for text extraction.
- Create structured markdown files with:
  - Appropriate headers and subheaders
  - Breakdown long paragraphs into point-form notes. Do not modify the sentences to make it short. Do not omit any information.
  - Clear section organization
  - If the information is important, format the text using bold, underline or callouts.
  - Do not add any other information
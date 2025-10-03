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
- Split the pdf using pdftk. 
- Command details:
	- "bg": Means BeGin
		- Split the pdf located in the main dir into a single pdf for each page. Name each splitted pdf file according to the page number. 
		- Convert the first pdf file to markdown file. Refer Technical Implementation below. Do not add any other information.
		- Move the converted pdf file into the `convertedpdf/` directory.
	- "nx": Means NeXt. Convert the next pdf file. Refer Technical Implementation below. If the previous page has context with continuation, rewrite back the context from the previous page and complete it on the current page. Do not add any other information. After conversion, move the converted pdf into `convertedpdf/` directory.
	- "ntpXX": Means Next Till Page XX. The same as "next" command above but continue to process the next page until the XX page number.
	- "nXXp": Means Next XX Pages. The same as "next till page XX" command above but according to number of page instead of page number.
	- "bgtf": Means BeGin Till Finish". This command is the same as "bg" above but continued with all page processing till finish including running "rs" command below.
	- "rs": Means restructure.
		- Analyze all markdown contents inside `convertednotes/` directory to outline the headers.
		- Create an `index.md` file that contain overview of the notes and links for each headers and their contents.
		- Do not add any other information outside from the PDF source.
		- Do not omit any information from the original markdown file. Make sure all the words are included (except the duplicated sentences from previous context)
		- Restructure the main headers inside their own markdown files instead of pages.
		- Create all the restructured markdown files inside a new directory named `structurednotes/`.
		- Each restructured markdown filenames is serially numbered except `index.md`.
		- From the context of the whole notes, determine the best main title and create a new markdown file with named `title.md` and here is the content:
			- It contains the main title inside a code block with underscore as space. E.g. ```Best_Fever_Therapy```.
			- As it will be used for a folder name, it must not exceed 30 characters but be more specifics as not to have duplicated folder names but be more specifics as not to have duplicated folder names.
		- After completed restructuration, run bash script `~/Scripts/p2mcleanup.sh` on the current directory.
	- "oneliner":
		- Split the pdf located in the main dir into a single pdf for each page. Name each splitted pdf file according to the page number.
		- Read each of the pdf splitted. Refer Technical Implementation below. Do not add any other information or left out any word or information.
		- This command skips the use of `convertedpdf/` and `convertednotes/` directories.
		- Analyze the content of each pdf. Create an `index.md` file that contain overview of the notes and links for each headers and their contents.
		- Do not add any other information outside from the PDF source.
		- Do not omit any information from the original markdown file. Make sure all the words are included (except the duplicated sentences from previous context)
		- Restructure the main headers inside their own markdown files instead of pages.
		- Create all the restructured markdown files inside a new directory named `structurednotes/`.
		- Each restructured markdown filenames is serially numbered except `index.md`.
		- From the context of the whole notes, determine the best main title and create a new markdown file with named `title.md` and here is the content:
			- It contains the main title inside a code block with underscore as space. E.g. ```Best_Fever_Therapy```.
			- As it will be used for a folder name, it must not exceed 30 characters but be more specifics as not to have duplicated folder names.
		- After completed restructuration, run bash script `~/Scripts/p2mcleanup.sh` on the current directory.

## Technical Implementation
- Use `pdftk` to split PDF files: `pdftk "filename.PDF" burst output "pdffiles/%02d.PDF"`
- Read the PDF to understand the structure and contents and convert them to texts or tables.
- Do not omit any information. Every word must be included.
- Do not use any bash tools for text extraction.
- Create structured markdown files with:
  - Appropriate headers and subheaders
  - Breakdown long paragraphs into point-form notes. Do not modify the sentences to make it short. Do not omit any information.
  - Clear section organization
  - If the information is important, format the text using bold, underline or callouts.
  - Do not add any other information
- Clean up temporary raw text files after conversion.
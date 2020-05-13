---
title: daybook
date: 31 December 2018
header: Linux Reference Manual
footer: daybook
section: 1
...

# NAME
`daybook` - diary writing utility

# SYNOPSIS
`daybook add|amend|show|search|render`

# DESCRIPTION
TODO

# OPTIONS
`add`
: opens `EDITOR` with an entry for today.

`amend`
: opens `EDITOR` with an entry for yesterday.

`show [pattern]`
: displays all diary entries matching a pattern in a pager. (default: all)

`search <pattern>`
: searches all entries for a pattern.

`render <file>`
: renders to a PDF file.

`-h, --help`
: shows this help screen.

# ENVIRONMENT VARIABLES
`DAYBOOK_DIR`
: the directory where all diary entries are stored (default: `$HOME/daybook`)

`DAYBOOK_TITLE`
: the title to render by (default: "Diary")

`DAYBOOK_AUTHOR`
: the diarist's name (default: user's real name or `$USER`)

`EDITOR`
: your favourite editor

# EXIT STATUS
0
: Successful completion.

1
: An invalid option was specified, or an error occurred.

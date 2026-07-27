package org

// Document is a "full" org-mode document, used for a new "readwise
// document" containing highlights. The "full" notion here being, what
// I need to sync from readwise to org, not the full representation of
// a org file.
type Document struct {
	Title       string
	Author      string
	Email       string
	Date        string
	FileTags    []string
	Identifier  string
	Category    string
	URL         string
	ReadwiseURL string
	Summary     string
	Highlights  []Highlight
}

// PartialDocument is a subset of org-mode used for an update of a
// "readwise document", thus containing new highlights.
type PartialDocument struct {
	Date       string
	Highlights []Highlight
}

// Highlight represent a readwise highlight in org-mode.
type Highlight struct {
	ID           string
	URL          string
	Location     string
	LocationType string
	Date         string
	Note         string
	Text         string
	Tags         []string
}

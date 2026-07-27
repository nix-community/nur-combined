package org

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"time"

	"github.com/vdemeester/home/tools/go-org-readwise/internal/readwise"
)

const (
	// denote-id-format "%Y%m%dT%H%M%S"
	denoteDateFormat = "20060102T150405"
	// org-date-format 2024-06-17 Mon 12:05
	orgDateFormat = "2006-01-02 Mon 15:04"
	// punctionation that is removed from file names.
	denoteExcludedPunctuationRegexpStr = "[][{}!@#$%^&*()=+'\"?,.|;:~`‘’“”/]*"
)

var (
	denoteExcludedPunctuationRegexp = regexp.MustCompile(denoteExcludedPunctuationRegexpStr)
	replaceHypensRegexp             = regexp.MustCompile("[-]+")
)

func Sync(ctx context.Context, target string, results []readwise.Result) error {
	for _, result := range results {
		// FIXME: handle the case where tags where added after
		// a sync. In that case, we want to try different
		// titles (without tags, …) ; most likely we want to
		// use a regexp to "detect" part of the thing.
		denotefilename := denoteFilename(result)
		filename := filepath.Join(target, denotefilename)
		if _, err := os.Stat(filename); err == nil {
			// Append to the file
			p := createPartialOrgDocument(result)
			content, err := convertPartialDocument(p)
			if err != nil {
				return err
			}
			f, err := os.OpenFile(filename, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0o600)
			if err != nil {
				return err
			}
			defer f.Close()
			if _, err = f.WriteString(string(content)); err != nil {
				return err
			}
		} else if errors.Is(err, os.ErrNotExist) {
			// Create the file
			d := createNewOrgDocument(result)
			content, err := convertDocument(d)
			if err != nil {
				return err
			}
			if err := os.WriteFile(filename, content, 0o644); err != nil {
				return err
			}
		} else {
			// Schrodinger: file may or may not exist. See err for details.
			// Therefore, do *NOT* use !os.IsNotExist(err) to test for file existence
			return err
		}
	}
	return nil
}

func createNewOrgDocument(r readwise.Result) Document {
	var filetags []string
	if len(r.BookTags) > 0 {
		filetags = make([]string, len(r.BookTags))
		for i, t := range r.BookTags {
			filetags[i] = sluggify(t.Name)
		}
	}
	return Document{
		Title:       r.Title,
		Author:      r.Author,
		ReadwiseURL: r.ReadwiseURL,
		URL:         r.SourceURL,
		Email:       "", // Figure out how to get the email
		Date:        r.FirstHighlightDate().Format(orgDateFormat),
		Identifier:  r.FirstHighlightDate().Format(denoteDateFormat),
		FileTags:    filetags,
		Category:    r.Category,
		Summary:     r.Summary,
		Highlights:  transformHighlights(r.Highlights),
	}
}

func createPartialOrgDocument(r readwise.Result) PartialDocument {
	now := time.Now()
	return PartialDocument{
		Date: now.Format(orgDateFormat),
		Highlights: transformHighlights(r.Highlights, func(h readwise.Highlight) bool {
			if h.HighlightedAt.After(now) {
				return true
			}
			return false
		}),
	}
}

func transformHighlights(highlights []readwise.Highlight, filters ...func(readwise.Highlight) bool) []Highlight {
	orgHighlights := []Highlight{}
	for _, h := range highlights {
		skip := false
		for _, filter := range filters {
			// If a filter returns false, skip the item
			if !filter(h) {
				skip = true
				break
			}
		}
		if skip {
			continue
		}
		var tags []string
		if len(h.Tags) > 0 {
			tags = make([]string, len(h.Tags))
			for i, t := range h.Tags {
				tags[i] = sluggify(t.Name)
			}
		}
		orgHighlights = append(orgHighlights, Highlight{
			ID:   fmt.Sprintf("%d", h.ID),
			URL:  h.ReadwiseURL,
			Date: h.HighlightedAt.Format(orgDateFormat),
			Note: h.Note,
			Text: h.Text,
		})
	}
	return orgHighlights
}

// See https://protesilaos.com/emacs/denote#h:4e9c7512-84dc-4dfb-9fa9-e15d51178e5d
// DATE==SIGNATURE--TITLE__KEYWORDS.EXTENSION
// Examples:
// - 20240611T100401--tuesday-11-june-2024__journal.org
// - 20240511T100401==readwise--foo__bar_baz.org
func denoteFilename(result readwise.Result) string {
	var date, signature, title, keywords string
	// The DATE field represents the date in year-month-day format
	// followed by the capital letter T (for “time”) and the
	// current time in hour-minute-second notation. The
	// presentation is compact: 20220531T091625. The DATE serves
	// as the unique identifier of each note and, as such, is also
	// known as the file’s ID or identifier.
	date = result.FirstHighlightDate().Format(denoteDateFormat)

	// File names can include a string of alphanumeric characters
	// in the SIGNATURE field. Signatures have no clearly defined
	// purpose and are up to the user to define. One use-case is
	// to use them to establish sequential relations between files
	// (e.g. 1, 1a, 1b, 1b1, 1b2, …).
	// We use signature to mark files synced from readwise.
	signature = "==readwise=" + result.Category

	// The TITLE field is the title of the note, as provided by
	// the user. It automatically gets downcased by default and is
	// also hyphenated (Sluggification of file name
	// components). An entry about “Economics in the Euro Area”
	// produces an economics-in-the-euro-area string for the TITLE
	// of the file name.
	title = sluggify(result.Title)

	// The KEYWORDS field consists of one or more entries
	// demarcated by an underscore (the separator is inserted
	// automatically). Each keyword is a string provided by the
	// user at the relevant prompt which broadly describes the
	// contents of the entry.
	if len(result.BookTags) > 0 {
		tags := make([]string, len(result.BookTags))
		for i, t := range result.BookTags {
			tags[i] = sluggify(t.Name)
		}
		keywords = "__" + strings.Join(tags, "_")
	}

	return date + strings.ToLower(fmt.Sprintf("%s--%s%s.org", signature, title, keywords))
}

func sluggify(s string) string {
	// Remove punctuation
	s = denoteExcludedPunctuationRegexp.ReplaceAllString(s, "")
	// Replace spaces with hypens
	s = strings.ReplaceAll(s, " ", "-")
	// Replace underscore with hypens
	s = strings.ReplaceAll(s, "_", "-")
	// Replace multiple hypens with a single one
	s = replaceHypensRegexp.ReplaceAllString(s, "-")
	// Remove any leading and trailing hypen
	s = strings.TrimPrefix(s, "-")
	s = strings.TrimSuffix(s, "-")
	return s
}

package readwise

import "time"

type Export struct {
	Count          int      `json:"count"`
	NextPageCursor *int     `json:"nextPageCursor"`
	Results        []Result `json:"results"`
}

type Result struct {
	UserBookId    int         `json:"use_book_id"`
	Title         string      `json:"title"`
	ReadableTitle string      `json:"readable_title"`
	CoverImageURL string      `json:"cover_image_url"`
	Author        string      `json:"author"`
	UniqueURL     string      `json:"unique_url"`
	BookTags      []Tag       `json:"book_tags"`
	Category      string      `json:"category"`
	DocumentNote  string      `json:"document_note"`
	Summary       string      `json:"summary"`
	ReadwiseURL   string      `json:"readwise_url"`
	Source        string      `json:"source"`
	SourceURL     string      `json:"source_url"`
	Highlights    []Highlight `json:"highlights"`
}

func (r Result) FirstHighlightDate() *time.Time {
	if len(r.Highlights) == 0 {
		return nil
	}
	var t time.Time
	for _, h := range r.Highlights {
		if h.HighlightedAt.After(t) {
			t = h.HighlightedAt
		}
	}
	return &t
}

type Highlight struct {
	Text          string    `json:"text"`
	ID            int       `json:"id"`
	Note          string    `json:"note"`
	ReadwiseURL   string    `json:"readwise_url"`
	HighlightedAt time.Time `json:"highlighted_at"`
	BookID        int       `json:"book_id"`
	URL           string    `json:"url"`
	Color         string    `json:"color"`
	Updated       time.Time `json:"updated"`
	Tags          []Tag     `json:"tags"`
}

type Tag struct {
	ID   int    `json:"id"`
	Name string `json:"name"`
}

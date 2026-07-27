package readwise

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

const (
	exportEndpoint     = "https://readwise.io/api/v2/export/?"
	FormatUpdatedAfter = "2006-01-02T15:04:05"
)

func FetchFromAPI(ctx context.Context, apikey string, updateAfter *time.Time) ([]Result, error) {
	results := []Result{}
	httpClient := &http.Client{}

	var e Export
	var err error
	var nextPageCursor *int = nil
	for {
		e, err = fetchExport(ctx, httpClient, apikey, updateAfter, nextPageCursor)
		if err != nil {
			return results, err
		}
		results = append(results, e.Results...)
		nextPageCursor = e.NextPageCursor
		if nextPageCursor == nil {
			// No more pages to fetch, we get out
			break
		}
	}

	return results, nil
}

func fetchExport(ctx context.Context, client *http.Client, apikey string, updateAfter *time.Time, nextPageCursor *int) (Export, error) {
	export := Export{}
	endpoint := exportEndpoint
	params := []string{}
	if updateAfter != nil {
		params = append(params, "updatedAfter="+updateAfter.Format(FormatUpdatedAfter))
	}
	if nextPageCursor != nil {
		params = append(params, fmt.Sprintf("pageCursor=%d", *nextPageCursor))
	}
	endpoint = endpoint + strings.Join(params, "&&")
	req, err := http.NewRequestWithContext(ctx, "GET", endpoint, nil)
	if err != nil {
		return export, err
	}
	req.Header.Add("Authorization", "Token "+apikey)
	resp, err := client.Do(req)
	if err != nil {
		return export, err
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return export, err
	}

	err = json.Unmarshal(body, &export)
	if err != nil {
		return export, err
	}

	return export, nil
}

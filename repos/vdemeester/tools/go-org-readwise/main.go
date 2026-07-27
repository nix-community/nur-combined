package main

import (
	"context"
	"flag"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/vdemeester/home/tools/go-org-readwise/internal/org"
	"github.com/vdemeester/home/tools/go-org-readwise/internal/readwise"
)

func main() {
	apiKeyFile := flag.String("apiKeyFile", "", "File to load the apiKey from. If empty, it will defer to the READWISE_KEY environment variable")
	targetFolder := flag.String("targetFolder", "", "Folder to write highlights (in org file) into")
	flag.Parse()

	if *targetFolder == "" {
		log.Fatal("-targetFolder is a required flag")
	}

	apiKeyData, err := os.ReadFile(*apiKeyFile)
	if err != nil && !os.IsNotExist(err) {
		log.Fatalf("Error reading apiKeyFile %s: %v", *apiKeyFile, err)
	}
	apikey := string(apiKeyData)
	if apikey == "" {
		apikey = os.Getenv("READWISE_KEY")
	}

	stateFile := filepath.Join(*targetFolder, ".readwise-sync.state")
	updateAfter, err := getUpdateAfterFromFile(stateFile)
	if err != nil {
		log.Fatalf("Error reading readwise state file from %s: %v", stateFile, err)
	}
	ctx := context.Background()
	results, err := readwise.FetchFromAPI(ctx, apikey, updateAfter)
	if err != nil {
		log.Fatalf("Error while fetching results: %v", err)
	}

	if err := org.Sync(ctx, *targetFolder, results); err != nil {
		log.Fatalf("Error syncing readwise and org file in %s folder: %v", *targetFolder, err)
	}
}

func getUpdateAfterFromFile(stateFile string) (*time.Time, error) {
	data, err := os.ReadFile(stateFile)
	if err != nil && !os.IsNotExist(err) {
		return nil, err
	}
	// If the file doesn't exists, do not fail
	if os.IsNotExist(err) {
		return nil, nil
	}
	t, err := time.Parse(readwise.FormatUpdatedAfter, string(data))
	if err != nil {
		return nil, err
	}
	return &t, nil
}

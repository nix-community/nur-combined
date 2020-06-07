// bus is a smal CLI tool that triggers home builds on build.sr.ht.
// It is designed to be run in a cron or systemd timer.
package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	yaml "gopkg.in/yaml.v2"
)

var (
	branch = flag.String("branch", "master", "branch to schedule")
	secret = flag.String("secret", "/etc/secrets/srht-token", "path to find sr.ht secret")
	builds = flag.String("builds", "/etc/nixos/.builds", "path to find builds manifests")
)

// Represents a builds.sr.ht build object as described on
// https://man.sr.ht/builds.sr.ht/api.md
type Build struct {
	Manifest string   `json:"manifest"`
	Note     string   `json:"note"`
	Tags     []string `json:"tags"`
}

// Represents a build trigger object as described on <the docs for
// this are currently down>
type Trigger struct {
	Action    string `json:"action"`
	Condition string `json:"condition"`
	To        string `json:"to"`
}

// Represents a build manifest for sourcehut.
type Manifest struct {
	Image    string                `json:"image"`
	Sources  []string              `json:"sources"`
	Secrets  []string              `json:"secrets"`
	Tasks    [](map[string]string) `json:"tasks"`
	Triggers []Trigger             `json:"triggers"`
}

func triggerBuild(token, name, manifest, branch string) {
	build := Build{
		Manifest: manifest,
		Note:     fmt.Sprintf("Nightly build of '%s' on '%s'", name, branch),
		Tags: []string{
			// my branch names tend to contain slashes, which are not valid
			// identifiers in sourcehut.
			"home", "nightly", strings.ReplaceAll(branch, "/", "_"), name,
		},
	}

	body, _ := json.Marshal(build)
	reader := ioutil.NopCloser(bytes.NewReader(body))

	req, err := http.NewRequest("POST", "https://builds.sr.ht/api/jobs", reader)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to create an HTTP request: %s", err)
		os.Exit(1)
	}

	req.Header.Add("Authorization", "token "+token)
	req.Header.Add("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		// This might indicate a temporary error on the sourcehut side, do
		// not fail the whole program.
		fmt.Fprintf(os.Stderr, "failed to send build.sr.ht request: %s", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		respBody, _ := ioutil.ReadAll(resp.Body)
		fmt.Fprintf(os.Stderr, "received non-success response from builds.sr.ht: %s (%v)", respBody, resp.Status)
		os.Exit(1)
	} else {
		fmt.Fprintf(os.Stdout, "triggered builds.sr.ht job for branch '%s'\n", branch)
	}
}

func prepareManifest(manifest []byte) ([]byte, error) {
	var m Manifest
	if err := yaml.Unmarshal(manifest, &m); err != nil {
		return manifest, err
	}
	m.Sources = append(m.Sources, "https://git.sr.ht/~vdemeester/home")
	return yaml.Marshal(m)
}

func main() {
	flag.Parse()
	token, err := ioutil.ReadFile(*secret)
	if err != nil {
		fmt.Fprint(os.Stderr, "sourcehut token could not be read.")
		os.Exit(1)
	}
	files, err := ioutil.ReadDir(*builds)
	if err != nil {
		fmt.Fprintf(os.Stderr, "cannot list builds manifest from %s: %v.\n", *builds, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stdout, "triggering builds for %v\n", *branch)
	for _, f := range files {
		path := filepath.Join(*builds, f.Name())
		manifest, err := ioutil.ReadFile(path)
		if err != nil {
			fmt.Fprintf(os.Stderr, "cannot read manifest %s: %v.\n", path, err)
			os.Exit(1)
		}
		manifest, err = prepareManifest(manifest)
		if err != nil {
			fmt.Fprintf(os.Stderr, "failed to prepare manifest %s: %v.\n", path, err)
			os.Exit(1)
		}
		triggerBuild(string(token), f.Name(), string(manifest), *branch)
	}
}

package main

import (
	"crypto/sha1"
	"encoding/hex"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// wait attempts and interval before the SPIRE server must answer. Variables so
// tests do not have to wait a real 30 seconds.
var (
	healthAttempts = 30
	healthInterval = time.Second
)

// registration is one declared entry: the identity a process must receive and
// the attributes that prove which process it is.
type registration struct {
	ParentID  string   `json:"parentID"`
	SpiffeID  string   `json:"spiffeID"`
	Selectors []string `json:"selectors"`
}

// manifest is the declarative set produced by mod/realm.nix: node -> entry name.
type manifest map[string]map[string]registration

// spireRegisterCommand reconciles the SPIRE server with the declared entries.
//
// The manifest is a build product; the state file records the entry IDs this
// command created last time. Reconciliation therefore updates entries in place,
// prunes only entries it created before, and leaves entries added by hand alone.
func spireRegisterCommand(args []string) error {
	flags := flag.NewFlagSet("spire-register", flag.ContinueOnError)
	server := flags.String("spire-server", "", "Path to the spire-server binary")
	socket := flags.String("socket", "", "SPIRE server admin API socket")
	manifestPath := flags.String("manifest", "", "JSON manifest of declared entries")
	statePath := flags.String("state", "", "JSON file listing previously created entry IDs")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if err := requireFlags(map[string]string{
		"spire-server": *server,
		"socket":       *socket,
		"manifest":     *manifestPath,
		"state":        *statePath,
	}); err != nil {
		return err
	}

	reconciler := &spireReconciler{server: *server, socket: *socket}
	if err := reconciler.wait(); err != nil {
		return err
	}
	return reconciler.reconcile(*manifestPath, *statePath)
}

type spireReconciler struct {
	server string
	socket string
}

// wait blocks until the server answers its health check. The unit starts with
// the server, so an immediate first attempt would always fail.
func (r *spireReconciler) wait() error {
	var last error
	for attempt := 0; attempt < healthAttempts; attempt++ {
		last = r.execute("healthcheck", "-socketPath", r.socket)
		if last == nil {
			return nil
		}
		time.Sleep(healthInterval)
	}
	return fmt.Errorf("SPIRE server did not become healthy: %w", last)
}

// reconcile applies the manifest, then removes entries that this command created
// previously and that the manifest no longer declares.
func (r *spireReconciler) reconcile(manifestPath, statePath string) error {
	desired, err := readManifest(manifestPath)
	if err != nil {
		return err
	}
	previous, err := readState(statePath)
	if err != nil {
		return err
	}

	current := make([]string, 0, len(desired))
	nodes := sortedKeys(desired)
	for _, node := range nodes {
		names := sortedKeys(desired[node])
		for _, name := range names {
			entry := desired[node][name]
			id := spireEntryID(node, name)
			current = append(current, id)
			if err := r.apply(id, node, name, entry); err != nil {
				return err
			}
		}
	}

	keep := make(map[string]bool, len(current))
	for _, id := range current {
		keep[id] = true
	}
	for _, id := range previous {
		if keep[id] {
			continue
		}
		if err := r.execute("entry", "delete", "-socketPath", r.socket, "-entryID", id); err != nil {
			return fmt.Errorf("delete stale entry %s: %w", id, err)
		}
		fmt.Fprintf(os.Stderr, "realm-helper spire-register: deleted %s\n", id)
	}

	return writeState(statePath, current)
}

// apply creates or updates one entry, depending on whether it already exists.
func (r *spireReconciler) apply(id, node, name string, entry registration) error {
	verb := "create"
	exists := r.execute("entry", "show", "-socketPath", r.socket, "-entryID", id) == nil
	if exists {
		verb = "update"
	}
	args := []string{
		"entry", verb,
		"-socketPath", r.socket,
		"-entryID", id,
		"-parentID", entry.ParentID,
		"-spiffeID", entry.SpiffeID,
		"-x509SVIDTTL", "3600",
	}
	for _, selector := range entry.Selectors {
		args = append(args, "-selector", selector)
	}
	if err := r.execute(args...); err != nil {
		return fmt.Errorf("%s entry %s (%s/%s): %w", verb, id, node, name, err)
	}
	fmt.Fprintf(os.Stderr, "realm-helper spire-register: %s %s %s (%s/%s)\n", verb, id, entry.SpiffeID, node, name)
	return nil
}

// execute runs the server CLI and folds its output into the error.
func (r *spireReconciler) execute(args ...string) error {
	output, err := exec.Command(r.server, args...).CombinedOutput()
	if err != nil {
		message := strings.TrimSpace(string(output))
		if message == "" {
			return err
		}
		return fmt.Errorf("%w: %s", err, message)
	}
	return nil
}

// spireEntryID derives the entry ID from the manifest key.
//
// The namespace and name string are unchanged from the Python implementation
// this replaced, so existing entries keep their IDs and a deployment does not
// create a second set of registrations.
func spireEntryID(node, name string) string {
	namespace, err := hex.DecodeString("6ba7b8119dad11d180b400c04fd430c8")
	if err != nil {
		panic(err)
	}
	digest := sha1.New()
	digest.Write(namespace)
	digest.Write([]byte("nyaw-realm:" + node + ":" + name))
	sum := digest.Sum(nil)

	var id [16]byte
	copy(id[:], sum[:16])
	id[6] = id[6]&0x0f | 0x50 // RFC 4122 version 5, name based
	id[8] = id[8]&0x3f | 0x80 // RFC 4122 variant
	return fmt.Sprintf("%x-%x-%x-%x-%x", id[0:4], id[4:6], id[6:8], id[8:10], id[10:16])
}

func readManifest(path string) (manifest, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read manifest: %w", err)
	}
	var declared manifest
	if err := json.Unmarshal(raw, &declared); err != nil {
		return nil, fmt.Errorf("parse manifest %s: %w", path, err)
	}
	for node, entries := range declared {
		for name, entry := range entries {
			if entry.ParentID == "" || entry.SpiffeID == "" || len(entry.Selectors) == 0 {
				return nil, fmt.Errorf("%s/%s: parentID, spiffeID and selectors are required", node, name)
			}
		}
	}
	return declared, nil
}

func readState(path string) ([]string, error) {
	raw, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read state: %w", err)
	}
	var ids []string
	if err := json.Unmarshal(raw, &ids); err != nil {
		return nil, fmt.Errorf("parse state %s: %w", path, err)
	}
	return ids, nil
}

// writeState replaces the state file atomically, so an interrupted run cannot
// leave a truncated list behind.
func writeState(path string, ids []string) error {
	encoded, err := json.Marshal(ids)
	if err != nil {
		return err
	}
	temporary := filepath.Join(filepath.Dir(path), filepath.Base(path)+".tmp")
	if err := os.WriteFile(temporary, encoded, 0o600); err != nil {
		return err
	}
	return os.Rename(temporary, path)
}

func sortedKeys[K string, V any](values map[K]V) []K {
	keys := make([]K, 0, len(values))
	for key := range values {
		keys = append(keys, key)
	}
	sort.Slice(keys, func(i, j int) bool { return keys[i] < keys[j] })
	return keys
}

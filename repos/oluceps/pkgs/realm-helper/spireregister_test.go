package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// fakeServer writes a stub spire-server that records its arguments and reports
// the IDs in `existing` as already registered.
func fakeServer(t *testing.T, existing []string, healthy bool) (serverPath, logPath string) {
	t.Helper()
	directory := t.TempDir()
	serverPath = filepath.Join(directory, "spire-server")
	logPath = filepath.Join(directory, "calls.log")

	existingFile := filepath.Join(directory, "existing")
	if err := os.WriteFile(existingFile, []byte(strings.Join(existing, "\n")+"\n"), 0o644); err != nil {
		t.Fatalf("write existing: %v", err)
	}

	health := "exit 0"
	if !healthy {
		health = "exit 1"
	}
	script := `#!/bin/sh
printf '%s\n' "$*" >> "` + logPath + `"
case "$1" in
  healthcheck) ` + health + ` ;;
  entry)
    if [ "$2" = "show" ]; then
      id=""
      while [ $# -gt 0 ]; do
        if [ "$1" = "-entryID" ]; then id="$2"; fi
        shift
      done
      grep -qx "$id" "` + existingFile + `" && exit 0
      exit 1
    fi
    exit 0
    ;;
esac
exit 0
`
	if err := os.WriteFile(serverPath, []byte(script), 0o755); err != nil {
		t.Fatalf("write fake server: %v", err)
	}
	return serverPath, logPath
}

func calls(t *testing.T, logPath string) []string {
	t.Helper()
	raw, err := os.ReadFile(logPath)
	if err != nil {
		t.Fatalf("read calls: %v", err)
	}
	return strings.Split(strings.TrimSpace(string(raw)), "\n")
}

func TestSpireEntryIDIsStable(t *testing.T) {
	// These values were produced by the Python implementation this replaced
	// (uuid.uuid5(NAMESPACE_URL, "nyaw-realm:<node>:<name>")). Matching them is
	// what keeps existing registrations from being recreated on deployment.
	cases := map[[2]string]string{
		{"eihort", "realm-egress-loki-s3"}:       "5c19bb69-5b52-5298-b1d5-e50bd94a2c94",
		{"abhoth", "realm-ingress-http"}:         "66331c22-22b5-52c2-b0c0-1188aae08528",
		{"eihort", "realm-helper-observability"}: "a970f0bd-4d2c-543a-98a1-4474395a92a1",
	}
	for key, want := range cases {
		if got := spireEntryID(key[0], key[1]); got != want {
			t.Errorf("spireEntryID(%q, %q) = %s, want %s", key[0], key[1], got, want)
		}
	}
}

func TestReconcileCreatesUpdatesAndPrunesOnlyItsOwnEntries(t *testing.T) {
	existingID := spireEntryID("node-a", "realm-egress-a")
	staleID := "11111111-2222-4333-8444-555555555555"
	handAddedID := "66666666-7777-4888-8999-aaaaaaaaaaaa"
	server, logPath := fakeServer(t, []string{existingID}, true)

	directory := t.TempDir()
	manifestPath := filepath.Join(directory, "registrations.json")
	statePath := filepath.Join(directory, "entries.json")

	declared := manifest{
		"node-a": {
			"realm-egress-a": {
				ParentID:  "spiffe://nyaw.xyz/agent/node-a",
				SpiffeID:  "spiffe://nyaw.xyz/service/a",
				Selectors: []string{"systemd:id:realm-egress-a.service", "unix:user:realm-a"},
			},
			"realm-egress-b": {
				ParentID:  "spiffe://nyaw.xyz/agent/node-a",
				SpiffeID:  "spiffe://nyaw.xyz/service/b",
				Selectors: []string{"systemd:id:realm-egress-b.service", "unix:user:realm-b"},
			},
		},
	}
	encoded, err := json.Marshal(declared)
	if err != nil {
		t.Fatalf("encode manifest: %v", err)
	}
	if err := os.WriteFile(manifestPath, encoded, 0o644); err != nil {
		t.Fatalf("write manifest: %v", err)
	}
	// The state lists one entry the manifest no longer declares: it must be
	// deleted. handAddedID stands for an entry created outside this tool; it is
	// not in the state, so the reconciler must never look at it.
	prior, err := json.Marshal([]string{existingID, staleID})
	if err != nil {
		t.Fatalf("encode state: %v", err)
	}
	if err := os.WriteFile(statePath, prior, 0o644); err != nil {
		t.Fatalf("write state: %v", err)
	}

	reconciler := &spireReconciler{server: server, socket: "/run/spire.sock"}
	if err := reconciler.wait(); err != nil {
		t.Fatalf("wait: %v", err)
	}
	if err := reconciler.reconcile(manifestPath, statePath); err != nil {
		t.Fatalf("reconcile: %v", err)
	}

	log := calls(t, logPath)
	joined := strings.Join(log, "\n")
	if !strings.Contains(joined, "entry update -socketPath /run/spire.sock -entryID "+existingID) {
		t.Errorf("existing entry was not updated:\n%s", joined)
	}
	if !strings.Contains(joined, "entry create -socketPath /run/spire.sock -entryID "+spireEntryID("node-a", "realm-egress-b")) {
		t.Errorf("new entry was not created:\n%s", joined)
	}
	if !strings.Contains(joined, "-selector systemd:id:realm-egress-b.service -selector unix:user:realm-b") {
		t.Errorf("selectors were not passed through:\n%s", joined)
	}
	if !strings.Contains(joined, "entry delete -socketPath /run/spire.sock -entryID "+staleID) {
		t.Errorf("stale entry was not deleted:\n%s", joined)
	}
	deletes := 0
	for _, call := range log {
		if strings.HasPrefix(call, "entry delete ") {
			deletes++
		}
	}
	if deletes != 1 {
		t.Errorf("expected exactly one delete, got %d:\n%s", deletes, joined)
	}
	if strings.Contains(joined, handAddedID) {
		t.Errorf("an entry outside the managed set was touched:\n%s", joined)
	}

	raw, err := os.ReadFile(statePath)
	if err != nil {
		t.Fatalf("read state: %v", err)
	}
	var recorded []string
	if err := json.Unmarshal(raw, &recorded); err != nil {
		t.Fatalf("parse state: %v", err)
	}
	want := []string{existingID, spireEntryID("node-a", "realm-egress-b")}
	if len(recorded) != len(want) {
		t.Fatalf("state holds %v, want %v", recorded, want)
	}
	for index := range want {
		if recorded[index] != want[index] {
			t.Fatalf("state holds %v, want %v", recorded, want)
		}
	}
}

func TestReconcileRejectsIncompleteDeclaration(t *testing.T) {
	directory := t.TempDir()
	manifestPath := filepath.Join(directory, "registrations.json")
	broken := manifest{"node-a": {"entry": {SpiffeID: "spiffe://nyaw.xyz/service/a"}}}
	encoded, err := json.Marshal(broken)
	if err != nil {
		t.Fatalf("encode manifest: %v", err)
	}
	if err := os.WriteFile(manifestPath, encoded, 0o644); err != nil {
		t.Fatalf("write manifest: %v", err)
	}

	reconciler := &spireReconciler{server: "/bin/true", socket: "/run/spire.sock"}
	err = reconciler.reconcile(manifestPath, filepath.Join(directory, "entries.json"))
	if err == nil || !strings.Contains(err.Error(), "parentID") {
		t.Fatalf("expected a missing-field error, got %v", err)
	}
}

func TestWaitFailsWhenServerStaysUnhealthy(t *testing.T) {
	previousAttempts, previousInterval := healthAttempts, healthInterval
	healthAttempts, healthInterval = 1, 0
	t.Cleanup(func() { healthAttempts, healthInterval = previousAttempts, previousInterval })

	server, _ := fakeServer(t, nil, false)
	reconciler := &spireReconciler{server: server, socket: "/run/spire.sock"}
	if err := reconciler.wait(); err == nil {
		t.Fatal("expected the wait to fail without a healthy server")
	}
}

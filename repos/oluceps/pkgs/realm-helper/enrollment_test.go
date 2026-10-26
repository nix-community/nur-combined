package main

import (
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// fakeAdminServer writes a spire-server stub that answers the two enrollment
// commands and records its arguments.
func fakeAdminServer(t *testing.T) (serverPath, logPath string) {
	t.Helper()
	directory := t.TempDir()
	serverPath = filepath.Join(directory, "spire-server")
	logPath = filepath.Join(directory, "calls.log")
	script := `#!/bin/sh
printf '%s\n' "$*" >> "` + logPath + `"
case "$1" in
  token) printf '{"value":"single-use-token"}\n' ;;
  bundle) printf '%s\n' '-----BEGIN CERTIFICATE-----' fixture '-----END CERTIFICATE-----' ;;
esac
`
	if err := os.WriteFile(serverPath, []byte(script), 0o755); err != nil {
		t.Fatalf("write fake server: %v", err)
	}
	return serverPath, logPath
}

func writeManifestFile(t *testing.T, declared manifest) string {
	t.Helper()
	encoded, err := json.Marshal(declared)
	if err != nil {
		t.Fatalf("encode manifest: %v", err)
	}
	path := filepath.Join(t.TempDir(), "registrations.json")
	if err := os.WriteFile(path, encoded, 0o644); err != nil {
		t.Fatalf("write manifest: %v", err)
	}
	return path
}

// captureStdout runs fn with os.Stdout redirected to a pipe.
func captureStdout(t *testing.T, fn func() error) (string, error) {
	t.Helper()
	reader, writer, err := os.Pipe()
	if err != nil {
		t.Fatalf("pipe: %v", err)
	}
	previous := os.Stdout
	os.Stdout = writer
	runErr := fn()
	writer.Close()
	os.Stdout = previous

	output, err := io.ReadAll(reader)
	if err != nil {
		t.Fatalf("read stdout: %v", err)
	}
	return string(output), runErr
}

// feedStdin runs fn with os.Stdin replaced by input.
func feedStdin(t *testing.T, input string, fn func() error) error {
	t.Helper()
	reader, writer, err := os.Pipe()
	if err != nil {
		t.Fatalf("pipe: %v", err)
	}
	if _, err := writer.WriteString(input); err != nil {
		t.Fatalf("write stdin: %v", err)
	}
	writer.Close()
	previous := os.Stdin
	os.Stdin = reader
	defer func() {
		os.Stdin = previous
		reader.Close()
	}()
	return fn()
}

// allowUnprivileged makes install-enrollment runnable inside the build sandbox.
func allowUnprivileged(t *testing.T) {
	t.Helper()
	previousEUID, previousRoot := geteuid, enrollmentRoot
	geteuid = func() int { return 0 }
	enrollmentRoot = filepath.Join(t.TempDir(), "realm-spire")
	t.Cleanup(func() { geteuid, enrollmentRoot = previousEUID, previousRoot })
}

func TestEnrollPrintsSingleUseEnrollment(t *testing.T) {
	server, logPath := fakeAdminServer(t)
	manifestPath := writeManifestFile(t, manifest{"node-a": {"entry": {}}})

	output, err := captureStdout(t, func() error {
		return enrollCommand([]string{
			"--spire-server", server,
			"--socket", "/run/spire.sock",
			"--manifest", manifestPath,
			"--trust-domain", "nyaw.xyz",
			"node-a",
		})
	})
	if err != nil {
		t.Fatalf("enroll: %v", err)
	}

	var enrollment struct {
		Node   string `json:"node"`
		Token  string `json:"token"`
		Bundle string `json:"bundle"`
	}
	if err := json.Unmarshal([]byte(output), &enrollment); err != nil {
		t.Fatalf("parse enrollment %q: %v", output, err)
	}
	if enrollment.Node != "node-a" || enrollment.Token != "single-use-token" {
		t.Fatalf("unexpected enrollment: %+v", enrollment)
	}
	if !strings.Contains(enrollment.Bundle, "BEGIN CERTIFICATE") {
		t.Fatalf("trust bundle was not passed through: %q", enrollment.Bundle)
	}

	calls := string(mustRead(t, logPath))
	if !strings.Contains(calls, "token generate -socketPath /run/spire.sock -spiffeID spiffe://nyaw.xyz/agent/node-a -ttl 600 -output json") {
		t.Errorf("join token was requested with unexpected arguments:\n%s", calls)
	}
	if !strings.Contains(calls, "bundle show -socketPath /run/spire.sock") {
		t.Errorf("trust bundle was not read from the server:\n%s", calls)
	}
}

func TestEnrollRejectsUnconfiguredNode(t *testing.T) {
	server, logPath := fakeAdminServer(t)
	manifestPath := writeManifestFile(t, manifest{"node-a": {}})

	err := enrollCommand([]string{
		"--spire-server", server,
		"--socket", "/run/spire.sock",
		"--manifest", manifestPath,
		"--trust-domain", "nyaw.xyz",
		"node-b",
	})
	if err == nil || !strings.Contains(err.Error(), "not a configured mesh node") {
		t.Fatalf("expected a configuration error, got %v", err)
	}
	if _, err := os.Stat(logPath); err == nil {
		t.Fatal("no token must be issued for an unknown node")
	}
}

func TestEnrollRequiresEveryOption(t *testing.T) {
	err := enrollCommand([]string{"node-a"})
	if err == nil || !strings.Contains(err.Error(), "is required") {
		t.Fatalf("expected a missing-option error, got %v", err)
	}
}

func TestInstallEnrollmentWritesTokenAndBundle(t *testing.T) {
	allowUnprivileged(t)
	systemctl := filepath.Join(t.TempDir(), "systemctl")
	systemctlLog := systemctl + ".log"
	script := "#!/bin/sh\nprintf '%s\\n' \"$*\" >> " + systemctlLog + "\n"
	if err := os.WriteFile(systemctl, []byte(script), 0o755); err != nil {
		t.Fatalf("write systemctl stub: %v", err)
	}

	input := `{"node":"node-a","token":"single-use-token","bundle":"bundle-pem"}`
	err := feedStdin(t, input, func() error {
		return installEnrollmentCommand([]string{"--node", "node-a", "--systemctl", systemctl})
	})
	if err != nil {
		t.Fatalf("install enrollment: %v", err)
	}

	info, err := os.Stat(enrollmentRoot)
	if err != nil {
		t.Fatalf("stat enrollment directory: %v", err)
	}
	if info.Mode().Perm() != 0o700 {
		t.Errorf("enrollment directory mode is %o, want 700", info.Mode().Perm())
	}
	for name, want := range map[string]string{
		"join-token":       "single-use-token",
		"trust-bundle.pem": "bundle-pem",
	} {
		path := filepath.Join(enrollmentRoot, name)
		if got := string(mustRead(t, path)); got != want {
			t.Errorf("%s holds %q, want %q", name, got, want)
		}
		info, err := os.Stat(path)
		if err != nil {
			t.Fatalf("stat %s: %v", name, err)
		}
		if info.Mode().Perm() != 0o600 {
			t.Errorf("%s mode is %o, want 600", name, info.Mode().Perm())
		}
	}
	if got := string(mustRead(t, systemctlLog)); !strings.Contains(got, "restart spire-agent.service") {
		t.Errorf("agent was not restarted, systemctl saw %q", got)
	}
}

func TestInstallEnrollmentRefusesForeignNode(t *testing.T) {
	allowUnprivileged(t)
	input := `{"node":"node-b","token":"t","bundle":"b"}`
	err := feedStdin(t, input, func() error {
		return installEnrollmentCommand([]string{"--node", "node-a", "--systemctl", "/bin/true"})
	})
	if err == nil || !strings.Contains(err.Error(), "not \"node-a\"") {
		t.Fatalf("expected a hostname mismatch, got %v", err)
	}
	if _, err := os.Stat(enrollmentRoot); err == nil {
		t.Fatal("a foreign enrollment must not create files")
	}
}

func TestInstallEnrollmentRefusesSymlinkedFiles(t *testing.T) {
	allowUnprivileged(t)
	if err := os.MkdirAll(enrollmentRoot, 0o700); err != nil {
		t.Fatalf("create enrollment directory: %v", err)
	}
	target := filepath.Join(t.TempDir(), "target")
	if err := os.WriteFile(target, []byte("original"), 0o644); err != nil {
		t.Fatalf("write target: %v", err)
	}
	if err := os.Symlink(target, filepath.Join(enrollmentRoot, "join-token")); err != nil {
		t.Fatalf("create symlink: %v", err)
	}

	input := `{"node":"node-a","token":"t","bundle":"b"}`
	err := feedStdin(t, input, func() error {
		return installEnrollmentCommand([]string{"--node", "node-a", "--systemctl", "/bin/true"})
	})
	if err == nil {
		t.Fatal("expected a symlink refusal")
	}
	if got := string(mustRead(t, target)); got != "original" {
		t.Fatalf("a root write followed a symlink: %q", got)
	}
}

func TestInstallEnrollmentRequiresRoot(t *testing.T) {
	previousEUID := geteuid
	geteuid = func() int { return 1000 }
	t.Cleanup(func() { geteuid = previousEUID })

	err := installEnrollmentCommand([]string{"--node", "node-a", "--systemctl", "/bin/true"})
	if err == nil || !strings.Contains(err.Error(), "must run as root") {
		t.Fatalf("expected a privilege error, got %v", err)
	}
}

func mustRead(t *testing.T, path string) []byte {
	t.Helper()
	raw, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read %s: %v", path, err)
	}
	return raw
}

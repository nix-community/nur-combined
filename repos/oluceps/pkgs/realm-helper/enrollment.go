package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
)

// enrollmentRoot is where the SPIRE Agent reads its join token and trust bundle.
// A variable so tests can point it at a temporary directory.
var enrollmentRoot = "/var/lib/realm-spire"

// geteuid is indirect so tests can exercise install-enrollment unprivileged.
var geteuid = os.Geteuid

// enrollCommand issues one single-use join token plus the public trust bundle
// for one mesh node, as JSON on stdout.
//
// The output is meant to be piped straight into `realm-install-enrollment` on
// the target node, over the existing root SSH trust boundary. Keeping the token
// out of files, shell variables and the Nix store is the point of the pipe.
//
// Only the keys of the manifest matter here: they are the realm-enabled node
// names, including nodes that declare no registrations yet.
func enrollCommand(args []string) error {
	flags := flag.NewFlagSet("enroll", flag.ContinueOnError)
	server := flags.String("spire-server", "", "Path to the spire-server binary")
	socket := flags.String("socket", "", "SPIRE server admin API socket")
	manifestPath := flags.String("manifest", "", "JSON manifest whose keys are the configured mesh nodes")
	trustDomain := flags.String("trust-domain", "", "SPIFFE trust domain")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if err := requireFlags(map[string]string{
		"spire-server": *server,
		"socket":       *socket,
		"manifest":     *manifestPath,
		"trust-domain": *trustDomain,
	}); err != nil {
		return err
	}
	if flags.NArg() != 1 {
		return errors.New("usage: realm-enroll NODE (configured mesh node)")
	}
	node := flags.Arg(0)

	raw, err := os.ReadFile(*manifestPath)
	if err != nil {
		return fmt.Errorf("read manifest: %w", err)
	}
	var nodes map[string]json.RawMessage
	if err := json.Unmarshal(raw, &nodes); err != nil {
		return fmt.Errorf("parse manifest %s: %w", *manifestPath, err)
	}
	if _, ok := nodes[node]; !ok {
		return fmt.Errorf("%s is not a configured mesh node", node)
	}

	// Ten minutes is long enough to copy one line to the target host.
	tokenOutput, err := exec.Command(*server,
		"token", "generate",
		"-socketPath", *socket,
		"-spiffeID", "spiffe://"+*trustDomain+"/agent/"+node,
		"-ttl", "600",
		"-output", "json",
	).Output()
	if err != nil {
		return fmt.Errorf("generate join token: %w", err)
	}
	var token struct {
		Value string `json:"value"`
	}
	if err := json.Unmarshal(tokenOutput, &token); err != nil {
		return fmt.Errorf("parse join token: %w", err)
	}

	bundle, err := exec.Command(*server, "bundle", "show", "-socketPath", *socket).Output()
	if err != nil {
		return fmt.Errorf("read trust bundle: %w", err)
	}

	return json.NewEncoder(os.Stdout).Encode(struct {
		Node   string `json:"node"`
		Token  string `json:"token"`
		Bundle string `json:"bundle"`
	}{node, token.Value, string(bundle)})
}

// installEnrollmentCommand consumes that JSON on the target node, writes the
// enrollment files and restarts the Agent.
//
// The hostname is compiled in by the module rather than read at runtime, so the
// command fails instead of enrolling a machine with an unexpected name.
func installEnrollmentCommand(args []string) error {
	flags := flag.NewFlagSet("install-enrollment", flag.ContinueOnError)
	node := flags.String("node", "", "Hostname this node must match")
	systemctl := flags.String("systemctl", "", "Path to systemctl")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if err := requireFlags(map[string]string{"node": *node, "systemctl": *systemctl}); err != nil {
		return err
	}
	if geteuid() != 0 {
		return errors.New("must run as root")
	}

	var enrollment struct {
		Node   string `json:"node"`
		Token  string `json:"token"`
		Bundle string `json:"bundle"`
	}
	if err := json.NewDecoder(os.Stdin).Decode(&enrollment); err != nil {
		return fmt.Errorf("read enrollment from stdin: %w", err)
	}
	if enrollment.Node != *node {
		return fmt.Errorf("enrollment is for %q, not %q", enrollment.Node, *node)
	}

	if err := os.MkdirAll(enrollmentRoot, 0o700); err != nil {
		return err
	}
	if err := os.Chmod(enrollmentRoot, 0o700); err != nil {
		return err
	}
	for _, file := range []struct {
		name  string
		value string
	}{
		{"join-token", enrollment.Token},
		{"trust-bundle.pem", enrollment.Bundle},
	} {
		if err := writeEnrollmentFile(filepath.Join(enrollmentRoot, file.name), file.value); err != nil {
			return err
		}
	}

	// The Agent only reads these files while starting.
	restart := exec.Command(*systemctl, "restart", "spire-agent.service")
	restart.Stdout = os.Stdout
	restart.Stderr = os.Stderr
	return restart.Run()
}

// writeEnrollmentFile replaces one enrollment file without following symlinks,
// so a pre-existing link cannot redirect a root write.
func writeEnrollmentFile(path, value string) error {
	file, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC|syscall.O_NOFOLLOW, 0o600)
	if err != nil {
		return err
	}
	defer file.Close()
	if _, err := file.WriteString(value); err != nil {
		return err
	}
	return file.Chmod(0o600)
}

// requireFlags reports the first required option that was left empty.
func requireFlags(values map[string]string) error {
	for _, name := range sortedKeys(values) {
		if values[name] == "" {
			return fmt.Errorf("--%s is required", name)
		}
	}
	return nil
}

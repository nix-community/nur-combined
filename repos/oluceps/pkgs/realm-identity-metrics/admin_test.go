package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"strings"
	"testing"
	"time"
)

func adminConfig() Config {
	c := testConfig()
	c.ServerAdminSocket = "/run/spire/server/private/api.sock"
	c.SPIREServerBinary = "/trusted/bin/spire-server"
	c.Nodes = []string{"eihort", "nodens"}
	return c
}
func agentsJSON(now time.Time) []byte {
	return []byte(fmt.Sprintf(`{"agents":[{"id":{"trust_domain":"example.org","path":"/spire/agent/http_fqdn/eihort"},"attestation_type":"http_fqdn","banned":false,"can_reattest":true,"x509svid_expires_at":"%d"},{"id":{"trust_domain":"example.org","path":"/spire/agent/http_fqdn/nodens"},"attestation_type":"http_fqdn","banned":false,"can_reattest":true,"x509svid_expires_at":"%d"},{"id":{"trust_domain":"example.org","path":"/spire/agent/join_token/DO_NOT_EXPORT"},"attestation_type":"join_token","banned":false,"can_reattest":false,"x509svid_expires_at":"1"}]}`, now.Add(time.Hour).Unix(), now.Add(time.Hour).Unix()))
}
func aliasJSON(c Config, node string) []byte {
	return []byte(fmt.Sprintf(`{"entries":[{"spiffe_id":{"trust_domain":"example.org","path":"/agent/%s"},"parent_id":{"trust_domain":"example.org","path":"/spire/agent/http_fqdn/%s"},"selectors":[{"type":"spiffe_id","value":%q}]}]}`, node, node, c.agentID(node)))
}
func TestAdminAgentsMetadata(t *testing.T) {
	now := time.Now()
	c := adminConfig()
	valid := string(agentsJSON(now))
	tests := []struct {
		name, raw string
		want      bool
	}{
		{"valid", valid, true},
		{"malformed", "{", false},
		{"missing_list", "{}", false},
		{"null_list", `{"agents":null}`, false},
		{"missing_expected", `{"agents":[]}`, false},
		{"missing_banned", strings.ReplaceAll(valid, `"banned":false,`, ""), false},
		{"missing_can_reattest", strings.ReplaceAll(valid, `"can_reattest":true,`, ""), false},
		{"banned", strings.ReplaceAll(valid, `"banned":false`, `"banned":true`), false},
		{"cannot_reattest", strings.ReplaceAll(valid, `"can_reattest":true`, `"can_reattest":false`), false},
		{"wrong_type", strings.ReplaceAll(valid, `"http_fqdn"`, `"join_token"`), false},
		{"wrong_id", strings.ReplaceAll(valid, `/spire/agent/http_fqdn/`, `/spire/agent/join_token/`), false},
		{"wrong_domain", strings.ReplaceAll(valid, `example.org`, `wrong.org`), false},
		{"invalid_expiry", strings.ReplaceAll(valid, fmt.Sprint(now.Add(time.Hour).Unix()), "bad"), false},
		{"expired", string(agentsJSON(now.Add(-2 * time.Hour))), false},
		{"trailing_json", valid + " {}", false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := parseAgents([]byte(tt.raw), c, now)
			if (err == nil) != tt.want {
				t.Fatalf("valid=%t, want %t", err == nil, tt.want)
			}
			if tt.want && (len(got) != 2 || !got[0].Valid || !got[1].Valid) {
				t.Fatal("registered cohort missing")
			}
		})
	}
	var envelope map[string][]json.RawMessage
	if json.Unmarshal([]byte(valid), &envelope) != nil {
		t.Fatal("fixture JSON")
	}
	envelope["agents"] = append(envelope["agents"], envelope["agents"][0])
	dup, _ := json.Marshal(envelope)
	if _, err := parseAgents(dup, c, now); err == nil {
		t.Fatal("duplicate agent accepted")
	}
}
func TestAliasMetadata(t *testing.T) {
	c := adminConfig()
	now := time.Now()
	valid := string(aliasJSON(c, "eihort"))
	tests := []struct {
		name, raw string
		want      bool
	}{
		{"valid", valid, true},
		{"malformed", "{", false},
		{"missing", "{}", false},
		{"empty", `{"entries":[]}`, false},
		{"wrong_spiffe_id", strings.Replace(valid, `"/agent/eihort"`, `"/agent/nodens"`, 1), false},
		{"wrong_parent", strings.Replace(valid, `"/spire/agent/http_fqdn/eihort"`, `"/spire/agent/join_token/DO_NOT_EXPORT"`, 1), false},
		{"wrong_selector", strings.Replace(valid, `"value":"spiffe://example.org/spire/agent/http_fqdn/eihort"`, `"value":"spiffe://example.org/spire/agent/http_fqdn/nodens"`, 1), false},
		{"wrong_selector_type", strings.Replace(valid, `"type":"spiffe_id"`, `"type":"unix"`, 1), false},
		{"expired", strings.Replace(valid, `"selectors":`, `"expires_at":"1","selectors":`, 1), false},
		{"bad_expiry", strings.Replace(valid, `"selectors":`, `"expires_at":"bad","selectors":`, 1), false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if aliasMatches([]byte(tt.raw), c, "eihort", now) != tt.want {
				t.Fatalf("alias valid differs from %t", tt.want)
			}
		})
	}
	var envelope map[string][]json.RawMessage
	if json.Unmarshal([]byte(valid), &envelope) != nil {
		t.Fatal("fixture JSON")
	}
	envelope["entries"] = append(envelope["entries"], envelope["entries"][0])
	dup, _ := json.Marshal(envelope)
	if aliasMatches(dup, c, "eihort", now) {
		t.Fatal("multiple alias entries accepted")
	}
}
func TestAdminCommandArgumentsAndFailures(t *testing.T) {
	c := adminConfig()
	e := newExporter(c, nil)
	e.command = func(ctx context.Context, binary string, args ...string) ([]byte, error) {
		if binary != c.SPIREServerBinary {
			t.Error("wrong command binary")
		}
		if len(args) > 0 && args[0] == "agent" {
			want := []string{"agent", "list", "-socketPath", c.ServerAdminSocket, "-output", "json"}
			if !reflect.DeepEqual(args, want) {
				t.Error("wrong agent arguments")
			}
			return agentsJSON(time.Now()), nil
		}
		node := "eihort"
		if len(args) > 3 && args[3] == c.aliasID("nodens") {
			node = "nodens"
		}
		want := []string{"entry", "show", "-spiffeID", c.aliasID(node), "-socketPath", c.ServerAdminSocket, "-output", "json"}
		if !reflect.DeepEqual(args, want) {
			t.Error("wrong alias arguments")
		}
		return aliasJSON(c, node), nil
	}
	if e.collectAgents(context.Background()).err != nil || e.collectAliases(context.Background()).err != nil {
		t.Fatal("valid admin collection failed")
	}
	e.command = func(context.Context, string, ...string) ([]byte, error) {
		return nil, fmt.Errorf("DO_NOT_LOG arbitrary failure")
	}
	for _, o := range []outcome{e.collectAgents(context.Background()), e.collectAliases(context.Background())} {
		if o.err == nil {
			t.Fatal("command failure reported success")
		}
		for _, m := range o.samples {
			if m.value != 0 {
				t.Fatal("command failure retained a green sample")
			}
		}
	}
}
func TestCommandHelper(t *testing.T) {
	if len(os.Args) < 2 {
		return
	}
	switch os.Args[len(os.Args)-1] {
	case "helper-output-limit":
		chunk := []byte(strings.Repeat("x", 1<<16))
		for i := 0; i < 200; i++ {
			if _, err := os.Stdout.Write(chunk); err != nil {
				os.Exit(0)
			}
		}
		os.Exit(0)
	case "helper-timeout":
		time.Sleep(10 * time.Second)
		os.Exit(0)
	case "helper-small":
		_, _ = fmt.Fprint(os.Stdout, `{"agents":[]}`)
		os.Exit(0)
	}
}
func TestCommandLimits(t *testing.T) {
	binary, err := os.Executable()
	if err != nil {
		t.Fatal("test executable path")
	}
	raw, err := runCommand(context.Background(), binary, "-test.run=^TestCommandHelper$", "--", "helper-small")
	if err != nil || string(raw) != `{"agents":[]}` {
		t.Fatal("bounded command failed")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if raw, err := runCommand(ctx, binary, "-test.run=^TestCommandHelper$", "--", "helper-output-limit"); err == nil || raw != nil {
		t.Fatal("large stdout accepted")
	}
	ctx2, cancel2 := context.WithTimeout(context.Background(), 40*time.Millisecond)
	defer cancel2()
	start := time.Now()
	if _, err := runCommand(ctx2, binary, "-test.run=^TestCommandHelper$", "--", "helper-timeout"); err == nil {
		t.Fatal("command timeout passed")
	}
	if time.Since(start) > time.Second {
		t.Fatal("command timeout exceeded bound")
	}
}

package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"os/exec"
	"strconv"
	"time"
)

const maxAdminBytes = 8 << 20

type commandRunner func(context.Context, string, ...string) ([]byte, error)

type cappedOutput struct {
	buffer   bytes.Buffer
	cancel   context.CancelFunc
	exceeded bool
}

func (b *cappedOutput) Write(p []byte) (int, error) {
	if len(p) > maxAdminBytes-b.buffer.Len() {
		b.exceeded = true
		b.cancel()
		return 0, errors.New("admin_output_limit")
	}
	return b.buffer.Write(p)
}
func runCommand(ctx context.Context, binary string, args ...string) ([]byte, error) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	cmd := exec.CommandContext(ctx, binary, args...)
	// Do not inherit environment variables. The absolute binary needs no PATH.
	cmd.Env = []string{"LANG=C", "LC_ALL=C"}
	out := &cappedOutput{cancel: cancel}
	cmd.Stdout = out
	cmd.Stderr = io.Discard
	cmd.WaitDelay = 200 * time.Millisecond
	if err := cmd.Run(); err != nil || out.exceeded {
		if out.exceeded {
			return nil, errors.New("admin_output_limit")
		}
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
		return nil, errors.New("admin_command")
	}
	return out.buffer.Bytes(), nil
}

type publicID struct {
	TrustDomain string `json:"trust_domain"`
	Path        string `json:"path"`
}

func (id publicID) matches(domain, path string) bool {
	return id.TrustDomain == domain && id.Path == path
}

type agentRecord struct {
	ID              publicID `json:"id"`
	AttestationType string   `json:"attestation_type"`
	Banned          *bool    `json:"banned"`
	CanReattest     *bool    `json:"can_reattest"`
	Expires         string   `json:"x509svid_expires_at"`
}
type agentResult struct {
	Node     string
	NotAfter int64
	Valid    bool
}

func parseAgents(raw []byte, c Config, now time.Time) ([]agentResult, error) {
	var envelope struct {
		Agents *[]agentRecord `json:"agents"`
	}
	if len(raw) > maxAdminBytes || json.Unmarshal(raw, &envelope) != nil || envelope.Agents == nil {
		return nil, errors.New("agents_json")
	}
	results := make([]agentResult, 0, len(c.Nodes))
	allValid := true
	for _, node := range c.Nodes {
		result := agentResult{Node: node}
		var matches []agentRecord
		for _, agent := range *envelope.Agents {
			if agent.ID.matches(c.TrustDomain, "/spire/agent/http_fqdn/"+node) {
				matches = append(matches, agent)
			}
		}
		if len(matches) == 1 {
			a := matches[0]
			expiry, err := strconv.ParseInt(a.Expires, 10, 64)
			if err == nil && expiry > 0 && expiry <= 253402300799 {
				result.NotAfter = expiry
			}
			result.Valid = result.NotAfter > now.Unix() && a.AttestationType == "http_fqdn" && a.Banned != nil && !*a.Banned && a.CanReattest != nil && *a.CanReattest
		}
		if !result.Valid {
			allValid = false
		}
		results = append(results, result)
	}
	if !allValid {
		return results, errors.New("agents_metadata")
	}
	return results, nil
}

type selector struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}
type entryRecord struct {
	ID        publicID   `json:"spiffe_id"`
	Parent    publicID   `json:"parent_id"`
	Selectors []selector `json:"selectors"`
	Expires   string     `json:"expires_at"`
}

func aliasMatches(raw []byte, c Config, node string, now time.Time) bool {
	_, valid := aliasMetadata(raw, c, node, now)
	return valid
}

func aliasMetadata(raw []byte, c Config, node string, now time.Time) (time.Time, bool) {
	var envelope struct {
		Entries []entryRecord `json:"entries"`
	}
	if len(raw) > maxAdminBytes || json.Unmarshal(raw, &envelope) != nil || len(envelope.Entries) != 1 {
		return time.Time{}, false
	}
	entry := envelope.Entries[0]
	var validUntil time.Time
	if entry.Expires != "" && entry.Expires != "0" {
		expiry, err := strconv.ParseInt(entry.Expires, 10, 64)
		if err != nil || expiry <= now.Unix() {
			return time.Time{}, false
		}
		validUntil = time.Unix(expiry, 0)
	}
	return validUntil, entry.ID.matches(c.TrustDomain, "/agent/"+node) && entry.Parent.matches(c.TrustDomain, "/spire/agent/http_fqdn/"+node) && len(entry.Selectors) == 1 && entry.Selectors[0].Type == "spiffe_id" && entry.Selectors[0].Value == c.agentID(node)
}

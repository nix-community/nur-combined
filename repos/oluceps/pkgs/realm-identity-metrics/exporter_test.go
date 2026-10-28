package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"
)

func TestConfig(t *testing.T) {
	valid := `{"node":"nodens","trust_domain":"example.org"}`
	path := filepath.Join(t.TempDir(), "config.json")
	load := func(raw string) (Config, error) {
		t.Helper()
		if os.WriteFile(path, []byte(raw), 0600) != nil {
			t.Fatal("write public config")
		}
		return readConfig(path)
	}
	c, err := load(valid)
	if err != nil {
		t.Fatal("default config failed")
	}
	if c.ListenAddress != "127.0.0.1:18494" || c.BundlePath != "/var/lib/realm-spire/trust-bundle.pem" || c.ServerAddress != "eihort.nyaw.xyz:8081" || c.WorkloadSocket != "/run/spire/agent/public/api.sock" {
		t.Fatal("wrong defaults")
	}
	for _, raw := range []string{"{}", valid + " {}", strings.Replace(valid, "nodens", "bad/node", 1), strings.Replace(valid, "nodens", "bad..node", 1), strings.Replace(valid, "example.org", "example.org/path", 1), strings.Replace(valid, "}", `,"unknown":true}`, 1), strings.Replace(valid, "}", `,"listen_address":"0.0.0.0:18494"}`, 1), strings.Replace(valid, "}", `,"listen_address":"localhost:18494"}`, 1), strings.Replace(valid, "}", `,"bundle_path":"relative"}`, 1), strings.Replace(valid, "}", `,"nodes":["nodens"]}`, 1)} {
		if _, err := load(raw); err == nil {
			t.Fatal("invalid configuration accepted")
		}
	}
	c = adminConfig()
	if c.validate() != nil {
		t.Fatal("valid Eihort admin config failed")
	}
	for _, mutate := range []func(*Config){func(c *Config) { c.Node = "nodens" }, func(c *Config) { c.SPIREServerBinary = "spire-server" }, func(c *Config) { c.SPIREServerBinary = "/trusted/bin/sh" }, func(c *Config) { c.Nodes = []string{"eihort", "eihort"} }, func(c *Config) { c.Nodes = nil }, func(c *Config) { c.ServerAdminSocket = "" }} {
		bad := adminConfig()
		mutate(&bad)
		if bad.validate() == nil {
			t.Fatal("unsafe admin config accepted")
		}
	}
}
func TestFailureStateAndFreshness(t *testing.T) {
	c := adminConfig()
	e := newExporter(c, nil)
	if e.healthy(time.Now()) {
		t.Fatal("initial health passed")
	}
	for name := range e.states {
		e.record(outcome{name: name})
	}
	if !e.healthy(time.Now()) {
		t.Fatal("successful collectors not healthy")
	}
	e.record(outcome{name: "bootstrap", err: errors.New("handshake failed")})
	if e.healthy(time.Now()) {
		t.Fatal("bootstrap failure not reflected in health")
	}
	var b bytes.Buffer
	e.metrics(&b, time.Now())
	output := b.String()
	for _, want := range []string{`realm_bootstrap_bundle_server_trust_valid{node="eihort"} 0`, `realm_identity_collector_success{node="eihort",collector="bootstrap"} 0`, `realm_identity_collector_errors_total{node="eihort",collector="bootstrap"} 1`, `realm_identity_collector_successes_total{node="eihort",collector="bootstrap"} 1`} {
		if !strings.Contains(output, want) {
			t.Fatalf("missing metric %s", want)
		}
	}
	if e.states["bootstrap"].lastSuccess.IsZero() {
		t.Fatal("last success was lost")
	}
	e.record(outcome{name: "bootstrap"})
	e.record(outcome{name: "aliases", samples: []sample{metric("realm_spire_alias_matches_expected", 1, "node", "eihort")}})
	future := time.Now().Add(freshnessLimit + time.Second)
	if e.healthy(future) {
		t.Fatal("stale health passed")
	}
	b.Reset()
	e.metrics(&b, future)
	output = b.String()
	if !strings.Contains(output, `realm_bootstrap_bundle_server_trust_valid{node="eihort"} 0`) || !strings.Contains(output, `realm_spire_alias_matches_expected{node="eihort"} 0`) {
		t.Fatal("stale green sample")
	}
}
func TestCanaryRotationAndNoStaleCertificate(t *testing.T) {
	c := testConfig()
	e := newExporter(c, nil)
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	_, first := ca.leaf(t, []string{c.canaryID()}, now.Add(-time.Minute), now.Add(time.Minute))
	_, second := ca.leaf(t, []string{c.canaryID()}, now.Add(-time.Minute), now.Add(time.Minute))
	current := first
	e.fetch = func(context.Context, Config) (canaryMetadata, error) { return canaryMetadata{Cert: current}, nil }
	o := e.collectCanary(context.Background())
	e.record(o)
	for _, m := range o.samples {
		if m.name == "realm_identity_last_rotation_timestamp_seconds" {
			t.Fatal("fabricated initial rotation")
		}
	}
	current = second
	o = e.collectCanary(context.Background())
	e.record(o)
	found := false
	for _, m := range o.samples {
		if m.name == "realm_identity_last_rotation_timestamp_seconds" && m.value > 0 {
			found = true
		}
	}
	if !found {
		t.Fatal("rotation missing")
	}
	e.fetch = func(context.Context, Config) (canaryMetadata, error) {
		return canaryMetadata{}, errors.New("unavailable")
	}
	e.record(e.collectCanary(context.Background()))
	var b bytes.Buffer
	e.metrics(&b, time.Now())
	for _, line := range strings.Split(b.String(), "\n") {
		if strings.HasPrefix(line, "realm_identity_certificate_") || strings.HasPrefix(line, "realm_identity_last_rotation_timestamp_seconds{") {
			t.Fatal("old canary certificate remained after failure")
		}
	}
}
func TestMetricsPublicMetadataAndHTTP(t *testing.T) {
	c := adminConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	c.BundlePath = bundleFile(t, ca.cert)
	cert, leaf := ca.leaf(t, []string{"spiffe://example.org/spire/server"}, now.Add(-time.Minute), now.Add(time.Minute))
	c.ServerAddress = startTLS(t, cert, 0)
	_, canary := ca.leaf(t, []string{c.canaryID()}, now.Add(-time.Minute), now.Add(time.Minute))
	e := newExporter(c, nil)
	e.fetch = func(context.Context, Config) (canaryMetadata, error) { return canaryMetadata{Cert: canary}, nil }
	e.command = func(_ context.Context, _ string, args ...string) ([]byte, error) {
		if args[0] == "agent" {
			return agentsJSON(now), nil
		}
		node := "eihort"
		if args[3] == c.aliasID("nodens") {
			node = "nodens"
		}
		return aliasJSON(c, node), nil
	}
	e.collect(context.Background())
	handler := e.handler()
	health := httptest.NewRecorder()
	handler.ServeHTTP(health, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if health.Code != 200 {
		t.Fatal("valid collection unhealthy")
	}
	response := httptest.NewRecorder()
	handler.ServeHTTP(response, httptest.NewRequest(http.MethodGet, "/metrics", nil))
	output := response.Body.String()
	if response.Code != 200 || !strings.Contains(response.Header().Get("Content-Type"), "version=0.0.4") {
		t.Fatal("invalid metrics response")
	}
	for _, forbidden := range []string{"PRIVATE KEY", "DO_NOT_EXPORT", "join_token", "serial_number", "/trusted/bin", "/run/spire", "service/other", string(leaf.Raw), string(canary.Raw)} {
		if strings.Contains(output, forbidden) {
			t.Fatal("nonpublic metadata in exposition")
		}
	}
	if !strings.Contains(output, `realm_bootstrap_bundle_server_trust_valid{node="eihort"} 1`) || !strings.Contains(output, `realm_identity_certificate_not_after_seconds{node="nodens",kind="agent",identity="spiffe://example.org/agent/nodens"}`) {
		t.Fatal("public certificate metric missing")
	}
	// Check each sample, its labels, and the declared metric type.
	linePattern := regexp.MustCompile(`^([a-z_]+)\{([a-z_]+="[a-zA-Z0-9:/._-]+"(?:,[a-z_]+="[a-zA-Z0-9:/._-]+")*)\} ([0-9.e+\-]+)$`)
	seen := map[string]bool{}
	for _, line := range strings.Split(output, "\n") {
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		match := linePattern.FindStringSubmatch(line)
		if match == nil {
			t.Fatal("invalid exposition line")
		}
		if _, err := strconv.ParseFloat(match[3], 64); err != nil {
			t.Fatal("invalid metric value")
		}
		key := match[1] + "{" + match[2] + "}"
		if seen[key] {
			t.Fatal("duplicate metric series")
		}
		seen[key] = true
		if !strings.Contains(output, "# TYPE "+match[1]+" "+metricType(match[1])) {
			t.Fatal("missing metric type")
		}
	}
	unknown := httptest.NewRecorder()
	handler.ServeHTTP(unknown, httptest.NewRequest(http.MethodGet, "/admin", nil))
	if unknown.Code != 404 {
		t.Fatal("unexpected admin route")
	}
	badMethod := httptest.NewRecorder()
	handler.ServeHTTP(badMethod, httptest.NewRequest(http.MethodPost, "/metrics", nil))
	if badMethod.Code != 405 {
		t.Fatal("metrics accepted write method")
	}
	e.record(outcome{name: "canary", err: errors.New("failed")})
	health = httptest.NewRecorder()
	handler.ServeHTTP(health, httptest.NewRequest(http.MethodGet, "/healthz", nil))
	if health.Code != 503 {
		t.Fatal("failed collection health passed")
	}
}
func TestCollectionTimeoutAndConcurrentScrapes(t *testing.T) {
	c := adminConfig()
	c.BundlePath = filepath.Join(t.TempDir(), "missing.pem")
	e := newExporter(c, nil)
	e.fetch = func(ctx context.Context, _ Config) (canaryMetadata, error) {
		<-ctx.Done()
		return canaryMetadata{}, ctx.Err()
	}
	e.command = func(ctx context.Context, _ string, _ ...string) ([]byte, error) { <-ctx.Done(); return nil, ctx.Err() }
	ctx, cancel := context.WithTimeout(context.Background(), 40*time.Millisecond)
	defer cancel()
	var wg sync.WaitGroup
	for i := 0; i < 8; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < 25; j++ {
				e.metrics(io.Discard, time.Now())
				_ = e.healthy(time.Now())
			}
		}()
	}
	start := time.Now()
	e.collect(ctx)
	wg.Wait()
	if time.Since(start) > time.Second {
		t.Fatal("collection ignored context timeout")
	}
	for _, s := range e.states {
		if s.success || s.errors != 1 || !s.lastSuccess.IsZero() {
			t.Fatal("failed collector reported success")
		}
	}
	// Simultaneous collection calls must not race on rotation or state.
	e.fetch = func(context.Context, Config) (canaryMetadata, error) { return canaryMetadata{}, errors.New("missing") }
	e.command = func(context.Context, string, ...string) ([]byte, error) { return nil, errors.New("missing") }
	for i := 0; i < 4; i++ {
		wg.Add(1)
		go func() { defer wg.Done(); e.collect(context.Background()) }()
	}
	wg.Wait()
}
func TestWorkloadAPITimeout(t *testing.T) {
	c := testConfig()
	c.WorkloadSocket = filepath.Join(t.TempDir(), "missing.sock")
	ctx, cancel := context.WithTimeout(context.Background(), 40*time.Millisecond)
	defer cancel()
	start := time.Now()
	if _, err := fetchCanary(ctx, c); err == nil {
		t.Fatal("missing Workload API passed")
	}
	if time.Since(start) > time.Second {
		t.Fatal("Workload API timeout exceeded bound")
	}
}
func TestSafeBoundedLog(t *testing.T) {
	var log bytes.Buffer
	e := newExporter(testConfig(), slog.New(slog.NewJSONHandler(&log, nil)))
	e.record(outcome{name: "canary", err: fmt.Errorf("DO_NOT_LOG %s", strings.Repeat("x", 10000))})
	if strings.Contains(log.String(), "DO_NOT_LOG") || log.Len() > 512 || !strings.Contains(log.String(), `"stage":"canary"`) || !strings.Contains(log.String(), `"reason":"collection_failed"`) {
		t.Fatal("unsafe collection log")
	}
}
func TestStaleCertificateMetadataExpires(t *testing.T) {
	s := collectorState{completed: time.Now(), success: true, samples: []sample{metric("realm_identity_certificate_not_after_seconds", 123, "node", "eihort", "kind", "canary", "identity", "spiffe://example.org/observer/identity/eihort")}}
	if len(currentSamples(s, time.Now().Add(freshnessLimit+time.Second))) != 0 {
		t.Fatal("stale certificate sample remained")
	}
}

func TestKnownExpiryClearsGreenBeforeFreshnessLimit(t *testing.T) {
	now := time.Now()
	e := newExporter(adminConfig(), nil)
	for name := range e.states {
		e.record(outcome{name: name, validUntil: now.Add(time.Second)})
	}
	e.record(outcome{name: "agents", validUntil: now.Add(time.Second), samples: []sample{
		metric("realm_identity_certificate_not_after_seconds", float64(now.Add(time.Second).Unix()), "node", "eihort", "kind", "agent", "identity", e.config.aliasID("eihort")),
		metric("realm_spire_agent_metadata_valid", 1, "node", "eihort"),
	}})
	e.record(outcome{name: "aliases", validUntil: now.Add(time.Second), samples: []sample{metric("realm_spire_alias_matches_expected", 1, "node", "eihort")}})
	future := now.Add(2 * time.Second)
	if e.healthy(future) {
		t.Fatal("known expiry retained healthy state")
	}
	var b bytes.Buffer
	e.metrics(&b, future)
	for _, want := range []string{`realm_bootstrap_bundle_server_trust_valid{node="eihort"} 0`, `realm_spire_agent_metadata_valid{node="eihort"} 0`, `realm_spire_alias_matches_expected{node="eihort"} 0`} {
		if !strings.Contains(b.String(), want) {
			t.Fatal("known expiry retained green metric")
		}
	}
}

type slowWriter struct {
	entered, release chan struct{}
	once             sync.Once
}

func (w *slowWriter) Write(p []byte) (int, error) {
	w.once.Do(func() { close(w.entered) })
	<-w.release
	return len(p), nil
}
func TestSlowScrapeDoesNotBlockCollection(t *testing.T) {
	e := newExporter(testConfig(), nil)
	writer := &slowWriter{entered: make(chan struct{}), release: make(chan struct{})}
	scraped := make(chan struct{})
	go func() { defer close(scraped); e.metrics(writer, time.Now()) }()
	defer func() { close(writer.release); <-scraped }()
	select {
	case <-writer.entered:
	case <-time.After(time.Second):
		t.Fatal("scrape did not start")
	}
	recorded := make(chan struct{})
	go func() { defer close(recorded); e.record(outcome{name: "canary", err: errors.New("missing")}) }()
	select {
	case <-recorded:
	case <-time.After(time.Second):
		t.Fatal("slow scrape blocked collection")
	}
}

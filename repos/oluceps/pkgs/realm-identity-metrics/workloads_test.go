package main

import (
	"bytes"
	"context"
	"crypto"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/spiffe/go-spiffe/v2/bundle/x509bundle"
	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/svid/x509svid"
)

func holderConfig() Config {
	c := testConfig()
	c.SystemctlBinary = "/trusted/bin/systemctl"
	c.Workloads = []WorkloadTarget{{Unit: "realm-egress-test-route.service", Identity: "spiffe://example.org/service/test", Address: "127.0.0.1:28001", Source: sourceGhostunnel}}
	return c
}
func observerCredentials(t *testing.T, ca testCA, c Config) canaryMetadata {
	t.Helper()
	now := time.Now()
	cert, leaf := ca.leaf(t, []string{c.canaryID()}, now.Add(-time.Minute), now.Add(time.Hour))
	return canaryMetadata{Cert: leaf, SVID: &x509svid.SVID{ID: spiffeid.RequireFromString(c.canaryID()), Certificates: []*x509.Certificate{leaf}, PrivateKey: cert.PrivateKey.(crypto.Signer)}, Bundle: x509bundle.FromX509Authorities(spiffeid.RequireTrustDomainFromString(c.TrustDomain), []*x509.Certificate{ca.cert})}
}
func serveHolderTLS(t *testing.T, cert tls.Certificate, trust *x509bundle.Bundle, authorize tlsconfig.Authorizer, handler http.Handler) string {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal("listen holder TLS")
	}
	svid := &x509svid.SVID{ID: spiffeid.RequireFromString(cert.Leaf.URIs[0].String()), Certificates: []*x509.Certificate{cert.Leaf}, PrivateKey: cert.PrivateKey.(crypto.Signer)}
	cfg := tlsconfig.MTLSServerConfig(svid, trust, authorize)
	cfg.MinVersion = tls.VersionTLS13
	server := &http.Server{Handler: handler, TLSConfig: cfg, ErrorLog: log.New(io.Discard, "", 0), ReadHeaderTimeout: time.Second}
	done := make(chan struct{})
	go func() { defer close(done); _ = server.ServeTLS(listener, "", "") }()
	t.Cleanup(func() { _ = server.Close(); _ = listener.Close(); <-done })
	return listener.Addr().String()
}
func TestWorkloadConfig(t *testing.T) {
	c := holderConfig()
	if c.validate() != nil {
		t.Fatal("valid target config failed")
	}
	c.Workloads = append(c.Workloads, WorkloadTarget{Unit: "realm-ingress-test-route.service", Identity: c.Workloads[0].Identity, Address: "[::1]:28002", Source: sourceCaddy})
	if c.validate() != nil {
		t.Fatal("multiple holders of one identity rejected")
	}
	for name, change := range map[string]func(*Config){
		"binary_missing":  func(c *Config) { c.SystemctlBinary = "" },
		"binary_relative": func(c *Config) { c.SystemctlBinary = "systemctl" },
		"binary_shell":    func(c *Config) { c.SystemctlBinary = "/bin/sh" },
		"remote":          func(c *Config) { c.Workloads[0].Address = "192.0.2.1:443" },
		"wildcard":        func(c *Config) { c.Workloads[0].Address = "0.0.0.0:443" },
		"hostname":        func(c *Config) { c.Workloads[0].Address = "localhost:443" },
		"scheme":          func(c *Config) { c.Workloads[0].Address = "https://127.0.0.1:443" },
		"path":            func(c *Config) { c.Workloads[0].Address = "127.0.0.1:443/_status" },
		"wrong_domain":    func(c *Config) { c.Workloads[0].Identity = "spiffe://wrong.org/service/test" },
		"identity_query":  func(c *Config) { c.Workloads[0].Identity += "?x=1" },
		"unknown_source":  func(c *Config) { c.Workloads[0].Source = "business_loaded" },
		"invalid_unit":    func(c *Config) { c.Workloads[0].Unit = "bad\nunit.service" },
		"socket_unit":     func(c *Config) { c.Workloads[0].Unit = "realm-test.socket" },
		"duplicate_unit":  func(c *Config) { c.Workloads = append(c.Workloads, c.Workloads[0]) },
		"duplicate_address": func(c *Config) {
			other := c.Workloads[0]
			other.Unit = "another.service"
			c.Workloads = append(c.Workloads, other)
		},
		"limit": func(c *Config) { c.Workloads = make([]WorkloadTarget, maxWorkloads+1) },
	} {
		t.Run(name, func(t *testing.T) {
			bad := holderConfig()
			change(&bad)
			if bad.validate() == nil {
				t.Fatal("invalid workload configuration accepted")
			}
		})
	}
	c = holderConfig()
	c.Workloads = nil
	for i := 0; i < maxWorkloads; i++ {
		c.Workloads = append(c.Workloads, WorkloadTarget{Unit: fmt.Sprintf("realm-egress-%04d-%s.service", i, strings.Repeat("x", 100)), Identity: "spiffe://example.org/service/test", Address: fmt.Sprintf("127.0.0.1:%d", 28000+i), Source: sourceGhostunnel})
	}
	raw, err := json.Marshal(c)
	if err != nil || len(raw) <= 64<<10 {
		t.Fatal("large config fixture")
	}
	path := filepath.Join(t.TempDir(), "config.json")
	if os.WriteFile(path, raw, 0600) != nil {
		t.Fatal("write config")
	}
	if _, err := readConfig(path); err != nil {
		t.Fatal("512 target config under 256 KiB rejected")
	}
	if os.WriteFile(path, bytes.Repeat([]byte(" "), maxConfigBytes+1), 0600) != nil {
		t.Fatal("write oversize config")
	}
	if _, err := readConfig(path); err == nil {
		t.Fatal("config limit not enforced")
	}
}
func TestWorkloadTLSIdentityTrustExpiryAndObserverAuth(t *testing.T) {
	c := holderConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(2*time.Hour))
	other := newCA(t, now.Add(-time.Hour), now.Add(2*time.Hour))
	observer := observerCredentials(t, ca, c)
	cases := []struct {
		name                           string
		signer                         testCA
		serverID                       string
		expiry                         time.Time
		wrongObserver, missingObserver bool
		source                         string
		valid                          bool
	}{
		{name: "ghostunnel_valid", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), source: sourceGhostunnel, valid: true},
		{name: "caddy_valid", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), source: sourceCaddy, valid: true},
		{name: "caddy_wrong_uri", signer: ca, serverID: "spiffe://example.org/service/other", expiry: now.Add(time.Hour), source: sourceCaddy},
		{name: "caddy_wrong_ca", signer: other, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), source: sourceCaddy},
		{name: "caddy_expired", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(-time.Second), source: sourceCaddy},
		{name: "caddy_wrong_observer_ca", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), wrongObserver: true, source: sourceCaddy},
		{name: "caddy_missing_observer", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), missingObserver: true, source: sourceCaddy},
		{name: "wrong_uri", signer: ca, serverID: "spiffe://example.org/service/other", expiry: now.Add(time.Hour), source: sourceGhostunnel},
		{name: "wrong_ca", signer: other, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), source: sourceGhostunnel},
		{name: "expired", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(-time.Second), source: sourceGhostunnel},
		{name: "wrong_observer_ca", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), wrongObserver: true, source: sourceGhostunnel},
		{name: "missing_observer", signer: ca, serverID: c.Workloads[0].Identity, expiry: now.Add(time.Hour), missingObserver: true, source: sourceGhostunnel},
	}
	for _, tt := range cases {
		t.Run(tt.name, func(t *testing.T) {
			target := c.Workloads[0]
			target.Source = tt.source
			cert, leaf := tt.signer.leaf(t, []string{tt.serverID}, now.Add(-time.Minute), tt.expiry)
			var requests atomic.Int32
			expectedPath := "/_metrics/prometheus"
			status := 200
			auth := tlsconfig.AuthorizeAny()
			if target.Source == sourceCaddy {
				expectedPath = "/"
				status = 204
				auth = tlsconfig.AuthorizeID(spiffeid.RequireFromString(c.canaryID()))
			}
			target.Address = serveHolderTLS(t, cert, observer.Bundle, auth, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				requests.Add(1)
				if r.Method != "GET" || r.URL.Path != expectedPath || r.URL.RawQuery != "" {
					t.Error("unsafe holder request")
				}
				w.WriteHeader(status)
			}))
			credentials := observer
			if tt.wrongObserver {
				credentials = observerCredentials(t, other, c)
				credentials.Bundle = observer.Bundle
			}
			if tt.missingObserver {
				credentials = canaryMetadata{}
			}
			got := observeHolder(context.Background(), target, credentials)
			if (got.err == nil) != tt.valid {
				t.Fatalf("observation valid=%t, want %t", got.err == nil, tt.valid)
			}
			if tt.valid && (requests.Load() != 1 || got.fingerprint != fingerprint(leaf) || !got.before.Equal(leaf.NotBefore) || !got.after.Equal(leaf.NotAfter) || got.fingerprint == fingerprint(observer.Cert)) {
				t.Fatal("wrong public certificate observation")
			}
			if !tt.valid && requests.Load() != 0 {
				t.Fatal("failed authentication reached HTTP handler")
			}
		})
	}
	// Caddy accepts only the observer ID, even when another client has a valid SVID.
	target := c.Workloads[0]
	target.Source = sourceCaddy
	cert, _ := ca.leaf(t, []string{target.Identity}, now.Add(-time.Minute), now.Add(time.Hour))
	target.Address = serveHolderTLS(t, cert, observer.Bundle, tlsconfig.AuthorizeID(spiffeid.RequireFromString(c.canaryID())), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		t.Error("other client reached Caddy")
		w.WriteHeader(204)
	}))
	wrong := observerCredentials(t, ca, c)
	client, leaf := ca.leaf(t, []string{"spiffe://example.org/service/other"}, now.Add(-time.Minute), now.Add(time.Hour))
	wrong.Cert = leaf
	wrong.SVID = &x509svid.SVID{ID: spiffeid.RequireFromString("spiffe://example.org/service/other"), Certificates: []*x509.Certificate{leaf}, PrivateKey: client.PrivateKey.(crypto.Signer)}
	if observeHolder(context.Background(), target, wrong).err == nil {
		t.Fatal("Caddy accepted an unauthorized observer")
	}
}
func TestHolderFixedPathsRedirectsAndBodyLimit(t *testing.T) {
	c := holderConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(2*time.Hour))
	observer := observerCredentials(t, ca, c)
	for _, mode := range []string{"redirect", "oversize", "wrong_status"} {
		t.Run(mode, func(t *testing.T) {
			cert, _ := ca.leaf(t, []string{c.Workloads[0].Identity}, now.Add(-time.Minute), now.Add(time.Hour))
			target := c.Workloads[0]
			target.Address = serveHolderTLS(t, cert, observer.Bundle, tlsconfig.AuthorizeAny(), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.URL.Path != "/_metrics/prometheus" {
					t.Error("collector followed a redirect or used status path")
				}
				switch mode {
				case "redirect":
					w.Header().Set("Location", "/_status")
					w.WriteHeader(302)
				case "oversize":
					_, _ = w.Write(bytes.Repeat([]byte("x"), maxHolderBodyBytes+1))
				case "wrong_status":
					w.WriteHeader(204)
				}
			}))
			if observeHolder(context.Background(), target, observer).err == nil {
				t.Fatal("invalid status response accepted")
			}
		})
	}
}
func activityJSON(targets []WorkloadTarget, states ...string) []byte {
	var b strings.Builder
	for i, t := range targets {
		state := "active"
		if i < len(states) {
			state = states[i]
		}
		fmt.Fprintf(&b, "ActiveState=%s\nId=%s\n\n", state, t.Unit)
	}
	return []byte(b.String())
}
func TestWorkloadActivityAndDormancy(t *testing.T) {
	c := holderConfig()
	for _, state := range []string{"inactive", "failed", "activating", "deactivating", "reloading"} {
		t.Run(state, func(t *testing.T) {
			e := newExporter(c, nil)
			e.command = func(_ context.Context, binary string, args ...string) ([]byte, error) {
				want := []string{"show", "--no-pager", "--property=Id,ActiveState", "--", c.Workloads[0].Unit}
				if binary != c.SystemctlBinary || !reflect.DeepEqual(args, want) {
					t.Error("unexpected systemctl command")
				}
				return activityJSON(c.Workloads, state), nil
			}
			ready := make(chan struct{})
			start := time.Now()
			o := e.collectWorkloads(context.Background(), ready, &canaryResult{})
			e.record(o)
			if time.Since(start) > time.Second {
				t.Fatal("inactive or failed unit waited for Workload API")
			}
			s := e.holders[c.Workloads[0].Unit]
			for name := range e.states {
				if name != "workloads" {
					e.record(outcome{name: name})
				}
			}
			if e.healthy(time.Now()) != (state == "inactive") {
				t.Fatal("dormant or failed holder health is incorrect")
			}
			if state == "inactive" {
				if o.err != nil || !s.dormant || s.success || s.errors != 0 {
					t.Fatal("incorrect dormant state")
				}
			} else {
				if o.err == nil || s.dormant || s.success || s.errors != 1 {
					t.Fatal("non-inactive unit reported healthy dormant")
				}
			}
			var b bytes.Buffer
			e.metrics(&b, time.Now())
			for _, line := range strings.Split(b.String(), "\n") {
				if strings.HasPrefix(line, "realm_workload_svid_not_after_seconds{") {
					t.Fatal("inactive or failed unit fabricated certificate")
				}
			}
		})
	}
	for _, raw := range []string{"", fmt.Sprintf("Id=%s\n", c.Workloads[0].Unit), string(activityJSON(c.Workloads)) + string(activityJSON(c.Workloads)), "Id=unregistered.service\nActiveState=inactive\n", "Id=" + c.Workloads[0].Unit + "\nActiveState=active\nBAD\n"} {
		if _, err := parseWorkloadActivity([]byte(raw), c.Workloads); err == nil {
			t.Fatal("missing or malformed unit metadata accepted")
		}
	}
	e := newExporter(c, nil)
	e.command = func(context.Context, string, ...string) ([]byte, error) {
		return nil, errors.New("private diagnostic must not enter logs")
	}
	ready := make(chan struct{})
	if e.collectWorkloads(context.Background(), ready, &canaryResult{}).err == nil || e.holders[c.Workloads[0].Unit].dormant {
		t.Fatal("failed systemctl became dormant")
	}
}
func TestWorkloadRotationFreshnessAndSourceLabels(t *testing.T) {
	c := holderConfig()
	e := newExporter(c, nil)
	target := c.Workloads[0]
	now := time.Now()
	o := holderObservation{before: now.Add(-time.Hour), after: now.Add(time.Hour), validUntil: now.Add(time.Hour), fingerprint: "first_public_fingerprint"}
	e.recordHolder(target, o)
	e.recordHolder(target, o)
	if !e.holders[target.Unit].rotated.IsZero() {
		t.Fatal("same leaf counted as rotation")
	}
	o.fingerprint = "second_public_fingerprint"
	e.recordHolder(target, o)
	if e.holders[target.Unit].rotated.IsZero() {
		t.Fatal("leaf change not observed")
	}
	var b bytes.Buffer
	e.metrics(&b, time.Now())
	output := b.String()
	if !strings.Contains(output, `source="ghostunnel_status_watch"`) || strings.Contains(output, "business_loaded") || strings.Contains(output, "public_fingerprint") || !strings.Contains(output, "realm_workload_svid_last_rotation_timestamp_seconds{") {
		t.Fatal("wrong observation labels or rotation signal")
	}
	b.Reset()
	e.metrics(&b, now.Add(freshnessLimit+time.Second))
	for _, line := range strings.Split(b.String(), "\n") {
		if strings.HasPrefix(line, "realm_workload_svid_not_after_seconds{") {
			t.Fatal("stale leaf metadata remained")
		}
	}
	e.recordHolder(target, holderObservation{err: errors.New("failed")})
	s := e.holders[target.Unit]
	if s.success || s.dormant || s.errors != 1 || s.observed.IsZero() || s.successes != 3 {
		t.Fatal("failure lost observation state")
	}
	b.Reset()
	e.metrics(&b, time.Now())
	if strings.Contains(b.String(), "realm_workload_svid_not_after_seconds{") {
		t.Fatal("failed observation retained old certificate")
	}
}
func TestWorkloadParallelDeadlineAndHTTPAvailability(t *testing.T) {
	c := holderConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(2*time.Hour))
	observer := observerCredentials(t, ca, c)
	cert, _ := ca.leaf(t, []string{c.Workloads[0].Identity}, now.Add(-time.Minute), now.Add(time.Hour))
	var active, peak atomic.Int32
	entered := make(chan struct{}, 64)
	address := serveHolderTLS(t, cert, observer.Bundle, tlsconfig.AuthorizeID(spiffeid.RequireFromString(c.canaryID())), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" || (r.URL.Path != "/" && r.URL.Path != "/_metrics/prometheus") {
			t.Error("wrong holder request")
		}
		n := active.Add(1)
		defer active.Add(-1)
		for {
			old := peak.Load()
			if n <= old || peak.CompareAndSwap(old, n) {
				break
			}
		}
		entered <- struct{}{}
		<-r.Context().Done()
	}))
	identity := c.Workloads[0].Identity
	c.Workloads = nil
	// A shared TLS server stands in for distinct production listener ports.
	for i := 0; i < 64; i++ {
		source := sourceCaddy
		if i%2 == 0 {
			source = sourceGhostunnel
		}
		c.Workloads = append(c.Workloads, WorkloadTarget{Unit: fmt.Sprintf("realm-holder-%d.service", i), Identity: identity, Source: source, Address: address})
	}
	e := newExporter(c, nil)
	e.command = func(context.Context, string, ...string) ([]byte, error) { return activityJSON(c.Workloads), nil }
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	ready := make(chan struct{})
	close(ready)
	var wg sync.WaitGroup
	wg.Add(1)
	start := time.Now()
	go func() { defer wg.Done(); e.record(e.collectWorkloads(ctx, ready, &canaryResult{metadata: observer})) }()
	// Check HTTP availability while multiple authenticated requests are pending.
	for i := 0; i < 2; i++ {
		select {
		case <-entered:
		case <-ctx.Done():
			wg.Wait()
			t.Fatal("TLS holder requests did not run concurrently")
		}
	}
	response := httptest.NewRecorder()
	scraped := make(chan struct{})
	go func() {
		e.handler().ServeHTTP(response, httptest.NewRequest("GET", "/metrics", nil))
		close(scraped)
	}()
	select {
	case <-scraped:
		if response.Code != 200 {
			t.Error("metrics unavailable during holder observations")
		}
	case <-ctx.Done():
		t.Error("metrics blocked by holder observations")
	}
	wg.Wait()
	<-scraped
	if time.Since(start) > 2*time.Second || peak.Load() > workloadParallelism || peak.Load() < 2 {
		t.Fatal("parallel observation bound or deadline failed")
	}
	for _, target := range c.Workloads {
		s := e.holders[target.Unit]
		if s.success || s.dormant || s.errors != 1 {
			t.Fatal("timed out observation appeared healthy")
		}
	}
}

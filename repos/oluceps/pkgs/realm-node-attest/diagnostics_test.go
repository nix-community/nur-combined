package nodeattest

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"testing"
	"time"

	"github.com/hashicorp/go-hclog"
	"github.com/spiffe/spire-plugin-sdk/pluginsdk"
	"github.com/spiffe/spire-plugin-sdk/plugintest"
	agentv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/agent/nodeattestor/v1"
	serverv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/server/nodeattestor/v1"
	configv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/service/common/config/v1"
	"google.golang.org/grpc"
)

type challengeAgentStream struct {
	grpc.ServerStream
	challenge []byte
	receives  int
}

func (*challengeAgentStream) Context() context.Context { return context.Background() }
func (*challengeAgentStream) Send(*agentv1.PayloadOrChallengeResponse) error {
	return nil
}
func (s *challengeAgentStream) Recv() (*agentv1.Challenge, error) {
	s.receives++
	if s.receives == 1 {
		return &agentv1.Challenge{Challenge: s.challenge}, nil
	}
	return nil, io.EOF
}

func TestFetchFailureDiagnostics(t *testing.T) {
	for _, tc := range []struct {
		name, phase, detail string
		status             int
		handler            http.HandlerFunc
		dialErr            error
		cancel             bool
	}{
		{name: "refused", phase: "round_trip", detail: "connection refused", dialErr: &net.OpError{Op: "dial", Net: "tcp", Err: &os.SyscallError{Syscall: "connect", Err: syscall.ECONNREFUSED}}},
		{name: "reset", phase: "round_trip", detail: "connection reset by peer", dialErr: &net.OpError{Op: "read", Net: "tcp", Err: syscall.ECONNRESET}},
		{name: "canceled", phase: "context", detail: "context canceled", cancel: true},
		{name: "not found", phase: "http_status", status: http.StatusNotFound, handler: func(w http.ResponseWriter, _ *http.Request) {
			w.WriteHeader(http.StatusNotFound)
			_, _ = io.WriteString(w, "secret-response-body")
		}},
		{name: "redirect", phase: "http_status", status: http.StatusFound, handler: func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Location", "http://secret-redirect.invalid/secret-challenge")
			w.WriteHeader(http.StatusFound)
		}},
		{name: "truncated body", phase: "read_body", status: http.StatusOK, detail: "unexpected EOF", handler: func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Content-Length", "100")
			_, _ = io.WriteString(w, "secret-response-body")
		}},
		{name: "oversized body", phase: "body_too_large", status: http.StatusOK, handler: func(w http.ResponseWriter, _ *http.Request) {
			_, _ = io.WriteString(w, strings.Repeat("x", MaxDocumentSize+1))
		}},
		{name: "encoding", phase: "content_encoding", status: http.StatusOK, handler: func(w http.ResponseWriter, _ *http.Request) {
			w.Header().Set("Content-Encoding", "secret-peer-header")
			_, _ = io.WriteString(w, "secret-response-body")
		}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			handler := tc.handler
			if handler == nil {
				handler = func(http.ResponseWriter, *http.Request) { t.Error("unexpected HTTP request") }
			}
			s := fixtureServer(t, handler)
			var events bytes.Buffer
			s.metrics = quietMetrics("server", "abhoth")
			s.metrics.events = &events
			if tc.dialErr != nil {
				s.dial = func(context.Context, string, string) (net.Conn, error) { return nil, tc.dialErr }
			}
			a := fixtureAgent(t, "/unused/control.sock")
			attempt, err := s.Begin(context.Background(), a.Payload())
			if err != nil {
				t.Fatal(err)
			}
			t.Cleanup(attempt.Close)
			ctx, cancel := context.WithCancel(context.Background())
			defer cancel()
			if tc.cancel {
				cancel()
			}
			if _, err := attempt.fetch(ctx); err == nil {
				t.Fatal("failed endpoint was accepted")
			}
			var event map[string]any
			if err := json.Unmarshal(events.Bytes(), &event); err != nil {
				t.Fatalf("expected one structured diagnostic: %v", err)
			}
			for key, want := range map[string]any{
				"@level": "warn", "@message": "realm_http_attestation_fetch_failed",
				"component": "server", "node": "abhoth", "stage": "fetch", "phase": tc.phase,
				"target": net.JoinHostPort(fixtureIP, strconv.Itoa(DefaultPort)), "http_status": float64(tc.status),
			} {
				if event[key] != want {
					t.Errorf("%s = %v, want %v", key, event[key], want)
				}
			}
			if tc.detail != "" && event["error"] != tc.detail {
				t.Errorf("error = %v, want %s", event["error"], tc.detail)
			}
			if event["duration_seconds"].(float64) < 0 {
				t.Error("negative duration")
			}
			for _, secret := range []string{attempt.challenge.ID, attempt.challenge.Nonce, PathPrefix, "secret-response-body", "secret-peer-header", "secret-redirect.invalid", "secret-challenge"} {
				if strings.Contains(events.String(), secret) {
					t.Errorf("diagnostic contains sensitive request or response data: %q", secret)
				}
			}
			timestamp, ok := event["@timestamp"].(string)
			if !ok {
				t.Fatal("missing @timestamp")
			}
			if _, err := time.Parse(hclogTimestampLayout, timestamp); err != nil {
				t.Fatalf("diagnostic @timestamp %q does not match go-plugin layout: %v", timestamp, err)
			}
		})
	}
}

func TestMetricRecordTimestampMatchesGoPluginLayout(t *testing.T) {
	m := quietMetrics("server", "abhoth")
	var events bytes.Buffer
	m.events = &events
	m.record("abhoth", "failure", "fetch", "endpoint_failed", 1500*time.Millisecond)
	var event map[string]any
	if err := json.Unmarshal(events.Bytes(), &event); err != nil {
		t.Fatal(err)
	}
	timestamp, ok := event["@timestamp"].(string)
	if !ok {
		t.Fatal("missing @timestamp")
	}
	if _, err := time.Parse(hclogTimestampLayout, timestamp); err != nil {
		t.Fatalf("event @timestamp %q does not match go-plugin layout: %v", timestamp, err)
	}
}

func TestAgentControlFailureDiagnostics(t *testing.T) {
	t.Run("missing socket", func(t *testing.T) {
		m := quietMetrics("agent", fixtureFQDN)
		var events bytes.Buffer
		m.events = &events
		secretSocket := filepath.Join(t.TempDir(), "secret-control.sock")
		a := fixtureAgent(t, secretSocket)
		defer a.Close()
		s, err := NewServer(fixtureConfig())
		if err != nil {
			t.Fatal(err)
		}
		attempt, err := s.Begin(context.Background(), a.Payload())
		if err != nil {
			t.Fatal(err)
		}
		defer attempt.Close()
		stream := &challengeAgentStream{challenge: attempt.Challenge()}
		if err := aidAttestation(stream, AgentConfig{FQDN: fixtureFQDN, TrustDomain: "nyaw.xyz", ControlSocket: secretSocket}, func(AgentConfig) (agentPluginAttempt, error) { return a, nil }, m); err == nil {
			t.Fatal("expected publish failure")
		}
		lines := strings.Split(strings.TrimSpace(events.String()), "\n")
		if len(lines) != 2 {
			t.Fatalf("expected control diagnostic and attestation event, got %d lines: %s", len(lines), &events)
		}
		var diag map[string]any
		if err := json.Unmarshal([]byte(lines[0]), &diag); err != nil {
			t.Fatal(err)
		}
		if diag["@message"] != "realm_http_attestation_control_failed" || diag["phase"] != "round_trip" || diag["method"] != http.MethodPut || diag["error"] != "no such file or directory" {
			t.Fatalf("unexpected control diagnostic: %v", diag)
		}
		if strings.Contains(events.String(), "secret-control") || strings.Contains(events.String(), attempt.challenge.ID) {
			t.Fatal("control diagnostic leaked socket path or challenge ID")
		}
	})

	t.Run("http status", func(t *testing.T) {
		socket := filepath.Join(t.TempDir(), "control.sock")
		listener, err := net.Listen("unix", socket)
		if err != nil {
			t.Fatal(err)
		}
		srv := &http.Server{Handler: http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			http.Error(w, "secret-responder-body", http.StatusTooManyRequests)
		})}
		go func() { _ = srv.Serve(listener) }()
		defer srv.Close()
		m := quietMetrics("agent", fixtureFQDN)
		var events bytes.Buffer
		m.events = &events
		a := fixtureAgent(t, socket)
		defer a.Close()
		s, err := NewServer(fixtureConfig())
		if err != nil {
			t.Fatal(err)
		}
		attempt, err := s.Begin(context.Background(), a.Payload())
		if err != nil {
			t.Fatal(err)
		}
		defer attempt.Close()
		stream := &challengeAgentStream{challenge: attempt.Challenge()}
		if err := aidAttestation(stream, AgentConfig{FQDN: fixtureFQDN, TrustDomain: "nyaw.xyz", ControlSocket: socket}, func(AgentConfig) (agentPluginAttempt, error) { return a, nil }, m); err == nil {
			t.Fatal("expected publish status failure")
		}
		lines := strings.Split(strings.TrimSpace(events.String()), "\n")
		var diag map[string]any
		if err := json.Unmarshal([]byte(lines[0]), &diag); err != nil {
			t.Fatal(err)
		}
		if diag["@message"] != "realm_http_attestation_control_failed" || diag["phase"] != "http_status" || diag["http_status"] != float64(http.StatusTooManyRequests) {
			t.Fatalf("unexpected status diagnostic: %v", diag)
		}
		if strings.Contains(events.String(), "secret-responder-body") {
			t.Fatal("control diagnostic leaked response body")
		}
	})
}

func TestResponderFailureDiagnostics(t *testing.T) {
	r, err := newResponder(ResponderConfig{FQDN: fixtureFQDN, Port: DefaultPort, ControlSocket: "/unused/control.sock"})
	if err != nil {
		t.Fatal(err)
	}
	var events bytes.Buffer
	r.metrics.events = &events
	req := httptest.NewRequest(http.MethodGet, "http://secret-host.example:18091"+PathPrefix+"secret-id", nil)
	r.public(httptest.NewRecorder(), req)
	lines := strings.Split(strings.TrimSpace(events.String()), "\n")
	if len(lines) != 2 {
		t.Fatalf("expected responder diagnostic and attestation event, got %d lines", len(lines))
	}
	var diag map[string]any
	if err := json.Unmarshal([]byte(lines[0]), &diag); err != nil {
		t.Fatal(err)
	}
	if diag["@message"] != "realm_http_attestation_responder_failed" || diag["phase"] != "host_mismatch" || diag["http_status"] != float64(http.StatusNotFound) {
		t.Fatalf("unexpected responder diagnostic: %v", diag)
	}
	if strings.Contains(events.String(), "secret-host") || strings.Contains(events.String(), "secret-id") {
		t.Fatal("responder diagnostic leaked host or ID")
	}
}

func TestPluginSetLoggerForwardsEventsThroughSPIRELogger(t *testing.T) {
	var logOut bytes.Buffer
	logger := hclog.New(&hclog.LoggerOptions{
		Level:      hclog.Trace,
		Output:     &logOut,
		JSONFormat: true,
	})
	plugin := new(ServerPlugin)
	var _ pluginsdk.NeedsLogger = plugin
	plugin.SetLogger(logger)
	m := newMetrics("server")
	m.setLogger(logger)
	m.register("abhoth")
	m.fetchFailure("abhoth", "[fdcc::5]:18091", "round_trip", 0, 0, time.Now(), &net.OpError{Op: "dial", Net: "tcp", Err: syscall.ECONNREFUSED})
	m.record("abhoth", "failure", "fetch", "endpoint_failed", time.Second)
	lines := strings.Split(strings.TrimSpace(logOut.String()), "\n")
	if len(lines) != 2 {
		t.Fatalf("expected 2 hclog lines, got %d: %s", len(lines), &logOut)
	}
	for i, wantMsg := range []string{"realm_http_attestation_fetch_failed", "realm_http_attestation"} {
		var entry map[string]any
		if err := json.Unmarshal([]byte(lines[i]), &entry); err != nil {
			t.Fatal(err)
		}
		if entry["@message"] != wantMsg || entry["@level"] != "warn" {
			t.Fatalf("unexpected hclog line %d: %v", i, entry)
		}
		ts, _ := entry["@timestamp"].(string)
		if _, err := time.Parse(hclogTimestampLayout, ts); err != nil {
			t.Fatalf("hclog @timestamp %q failed go-plugin layout: %v", ts, err)
		}
	}

	var rpcOut bytes.Buffer
	rpcLogger := hclog.New(&hclog.LoggerOptions{
		Level:      hclog.Trace,
		Output:     &rpcOut,
		JSONFormat: true,
	})
	serverPlugin := new(ServerPlugin)
	client := new(serverv1.NodeAttestorPluginClient)
	plugintest.ServeInBackground(t, plugintest.Config{
		PluginServer:   serverv1.NodeAttestorPluginServer(serverPlugin),
		PluginClient:   client,
		ServiceServers: []pluginsdk.ServiceServer{configv1.ConfigServiceServer(serverPlugin)},
		Logger:         rpcLogger,
	})
	stream, err := client.Attest(context.Background())
	if err != nil {
		t.Fatal(err)
	}
	_, _ = stream.Recv()
	if !strings.Contains(rpcOut.String(), `"@message":"realm_http_attestation"`) || !strings.Contains(rpcOut.String(), `"not_configured"`) {
		t.Fatalf("expected SDK Init SetLogger to emit attestation event, got: %s", &rpcOut)
	}
}

func TestFetchDiagnosticsRedactErrorURLsAndPeerText(t *testing.T) {
	m := quietMetrics("server", "abhoth")
	var events bytes.Buffer
	m.events = &events
	err := &url.Error{Op: "Get", URL: "http://secret-url.invalid/secret-challenge", Err: errors.New("secret-peer-error")}
	m.fetchFailure("abhoth", "[fdcc::7]:18091", "round_trip", 0, 0, time.Now(), err)
	if strings.Contains(events.String(), "secret-") {
		t.Fatal("diagnostic leaked URL or arbitrary error text")
	}
	var event map[string]any
	if err := json.Unmarshal(events.Bytes(), &event); err != nil {
		t.Fatal(err)
	}
	if event["error_type"] != "*errors.errorString" || event["error"] != safeFetchError(err) {
		t.Fatalf("missing safe error details: %v", event)
	}
}

func TestSuccessfulFetchDoesNotEmitFailureDiagnostic(t *testing.T) {
	s := fixtureServer(t, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = io.WriteString(w, "proof-fixture")
	}))
	var events bytes.Buffer
	s.metrics = quietMetrics("server", "abhoth")
	s.metrics.events = &events
	a := fixtureAgent(t, "/unused/control.sock")
	attempt, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	defer attempt.Close()
	body, err := attempt.fetch(context.Background())
	if err != nil || string(body) != "proof-fixture" || events.Len() != 0 {
		t.Fatalf("successful fetch changed: body=%q error=%v events=%s", body, err, &events)
	}
}

package nodeattest

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	serverv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/server/nodeattestor/v1"
	"google.golang.org/grpc"
)

func quietMetrics(component string, nodes ...string) *metricsRegistry {
	m := newMetrics(component)
	m.events = nil
	m.register(nodes...)
	return m
}

func scrapeMetrics(m *metricsRegistry) string {
	w := httptest.NewRecorder()
	m.ServeHTTP(w, httptest.NewRequest(http.MethodGet, "/metrics", nil))
	return w.Body.String()
}

func TestAgentMetricsProofSubmissionAndEarlyEOF(t *testing.T) {
	for _, tc := range []struct {
		name, outcome, stage, reason string
		recvErr, respondErr          error
		sendErrAt                    int
	}{
		{name: "submission", outcome: "success", stage: "response", reason: "proof_submitted"},
		{name: "early EOF", outcome: "skipped", stage: "challenge", reason: "no_challenge", recvErr: io.EOF},
		{name: "challenge receive", outcome: "failure", stage: "challenge", reason: "stream_error", recvErr: io.ErrUnexpectedEOF},
		{name: "publish", outcome: "failure", stage: "publish", reason: "publish_failed", respondErr: &observationError{err: errors.New("secret-proof"), stage: "publish", reason: "publish_failed"}},
		{name: "response send", outcome: "failure", stage: "response", reason: "stream_error", sendErrAt: 2},
	} {
		t.Run(tc.name, func(t *testing.T) {
			m := quietMetrics("agent", fixtureFQDN)
			var events bytes.Buffer
			m.events = &events
			attempt := &fakeAgentAttempt{respondErr: tc.respondErr}
			stream := &fakeAgentStream{attempt: attempt, recvErr: tc.recvErr, sendErrAt: tc.sendErrAt}
			_ = aidAttestation(stream, AgentConfig{FQDN: fixtureFQDN}, func(AgentConfig) (agentPluginAttempt, error) { return attempt, nil }, m)
			key := metricLabels{fixtureFQDN, tc.outcome, tc.stage, tc.reason}
			if len(m.totals) != 1 || m.totals[key] != 1 || m.pending[fixtureFQDN] != 0 {
				t.Fatalf("unexpected completion metrics: %+v, pending=%d", m.totals, m.pending[fixtureFQDN])
			}
			if (m.lastSuccess[fixtureFQDN] > 0) != (tc.outcome == "success") {
				t.Fatal("incorrect success timestamp")
			}
			if m.durations[durationLabels{fixtureFQDN, tc.outcome}].count != 1 {
				t.Fatal("missing duration")
			}
			var event map[string]any
			if json.Unmarshal(events.Bytes(), &event) != nil || event["reason"] != tc.reason || event["node"] != fixtureFQDN {
				t.Fatal("invalid structured event")
			}
			if strings.Contains(events.String(), "secret-proof") {
				t.Fatal("event contains proof data")
			}
		})
	}
}

type proofMetricsStream struct {
	grpc.ServerStream
	t                        *testing.T
	agent                    *AgentAttempt
	proof                    *atomic.Value
	metrics                  *metricsRegistry
	payload                  []byte
	challenge                challenge
	receives                 int
	badProof, failAttributes bool
}

func (*proofMetricsStream) Context() context.Context { return context.Background() }
func (s *proofMetricsStream) Recv() (*serverv1.AttestRequest, error) {
	s.receives++
	if s.receives == 1 {
		return &serverv1.AttestRequest{Request: &serverv1.AttestRequest_Payload{Payload: s.payload}}, nil
	}
	body, _ := json.Marshal(ready{Version: 1, ID: s.challenge.ID})
	return &serverv1.AttestRequest{Request: &serverv1.AttestRequest_ChallengeResponse{ChallengeResponse: body}}, nil
}
func (s *proofMetricsStream) Send(response *serverv1.AttestResponse) error {
	if raw := response.GetChallenge(); raw != nil {
		if err := json.Unmarshal(raw, &s.challenge); err != nil {
			return err
		}
		s.metrics.mu.Lock()
		pending := s.metrics.pending["abhoth"]
		s.metrics.mu.Unlock()
		if pending != 1 {
			s.t.Error("challenge did not reserve pending capacity")
		}
		proof, err := signProof(s.agent.key, raw)
		if err != nil {
			return err
		}
		if s.badProof {
			proof = []byte(`{}`)
		}
		s.proof.Store(proof)
		return nil
	}
	if s.failAttributes {
		return errors.New("secret-request-data")
	}
	return nil
}

func TestServerMetricsRealVerificationQuotaAndAttributes(t *testing.T) {
	for _, name := range []string{"success", "invalid proof", "attributes send failure", "quota"} {
		t.Run(name, func(t *testing.T) {
			var proof atomic.Value
			proof.Store([]byte(`{}`))
			s := fixtureServer(t, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(proof.Load().([]byte)) }))
			m := quietMetrics("server", "abhoth")
			var events bytes.Buffer
			m.events = &events
			s.metrics = m
			p := &ServerPlugin{metrics: m, nodes: s.nodes, begin: func(ctx context.Context, payload []byte) (serverPluginAttempt, error) { return s.Begin(ctx, payload) }}
			a := fixtureAgent(t, "/unused/control.sock")
			count := 1
			if name == "quota" {
				count = 7
			}
			for i := range count {
				stream := &proofMetricsStream{t: t, agent: a, proof: &proof, metrics: m, payload: a.Payload(), badProof: name == "invalid proof", failAttributes: name == "attributes send failure"}
				err := p.Attest(stream)
				wantFailure := name == "invalid proof" || name == "attributes send failure" || i == 6
				if (err != nil) != wantFailure {
					t.Fatalf("unexpected attestation error at %d", i)
				}
			}
			stage, reason, successes := "attributes", "attributes_sent", uint64(1)
			if name == "invalid proof" {
				stage, reason, successes = "verify", "invalid_proof", 0
			}
			if name == "attributes send failure" {
				stage, reason, successes = "attributes", "stream_error", 0
			}
			if name == "quota" {
				stage, reason, successes = "quota", "rate_limit", 6
			}
			if m.totals[metricLabels{"abhoth", "success", "attributes", "attributes_sent"}] != successes {
				t.Fatal("incorrect server success count")
			}
			if successes != 1 && m.totals[metricLabels{"abhoth", "failure", stage, reason}] != 1 {
				t.Fatal("missing server failure")
			}
			if (m.lastSuccess["abhoth"] > 0) != (successes > 0) || m.pending["abhoth"] != 0 {
				t.Fatal("incorrect server gauges")
			}
			text := scrapeMetrics(m)
			if name == "quota" && !strings.Contains(text, `realm_http_attestation_rejections_total{component="server",node="abhoth",stage="quota",reason="rate_limit"} 1`) {
				t.Fatal("missing quota rejection")
			}
			for _, forbidden := range []string{s.config.TrustDomain + "/spire/agent", "secret-request-data", "challenge_id", "nonce", "bootstrap_jwk"} {
				if strings.Contains(events.String(), forbidden) || strings.Contains(text, forbidden) {
					t.Fatal("observation contains request data")
				}
			}
		})
	}
}

func TestUnknownClaimsAndCapacityUseBoundedLabels(t *testing.T) {
	s, err := NewServer(fixtureConfig())
	if err != nil {
		t.Fatal(err)
	}
	m := quietMetrics("server", "abhoth")
	var events bytes.Buffer
	m.events = &events
	s.metrics = m
	p := &ServerPlugin{metrics: m, nodes: s.nodes, begin: func(ctx context.Context, payload []byte) (serverPluginAttempt, error) { return s.Begin(ctx, payload) }}
	a := fixtureAgent(t, "/unused/control.sock")
	var claim request
	_ = json.Unmarshal(a.Payload(), &claim)
	for i := range 100 {
		claim.FQDN = fmt.Sprintf("unknown-%d.attacker.example", i)
		payload, _ := json.Marshal(claim)
		_ = p.Attest(&fakeServerStream{requests: []*serverv1.AttestRequest{{Request: &serverv1.AttestRequest_Payload{Payload: payload}}}})
	}
	if len(m.totals) != 1 || m.totals[metricLabels{"unknown", "failure", "payload", "unknown_node"}] != 100 {
		t.Fatal("unknown claims expanded metric labels")
	}
	if strings.Contains(events.String(), "attacker.example") || strings.Contains(scrapeMetrics(m), "attacker.example") {
		t.Fatal("unknown node escaped into observations")
	}
	var attempts []*ServerAttempt
	for range 32 {
		attempt, err := s.Begin(context.Background(), a.Payload())
		if err != nil {
			t.Fatal(err)
		}
		attempts = append(attempts, attempt)
	}
	if m.pending["abhoth"] != 32 {
		t.Fatal("incorrect capacity use")
	}
	_ = p.Attest(&fakeServerStream{requests: []*serverv1.AttestRequest{{Request: &serverv1.AttestRequest_Payload{Payload: a.Payload()}}}})
	if m.totals[metricLabels{"abhoth", "failure", "start", "capacity"}] != 1 {
		t.Fatal("missing capacity rejection")
	}
	for _, attempt := range attempts {
		attempt.Close()
		attempt.Close()
	}
	if m.pending["abhoth"] != 0 {
		t.Fatal("capacity did not return to zero")
	}
}

func TestRegistryConcurrentScrapesAndUntrustedLabels(t *testing.T) {
	m := quietMetrics("server", "abhoth")
	var events bytes.Buffer
	m.events = &events
	const workers, operations = 12, 50
	var wg sync.WaitGroup
	for i := range workers {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			for j := range operations {
				m.pendingAdd("abhoth", 1)
				m.record("abhoth", "success", "attributes", "attributes_sent", time.Second)
				m.pendingAdd("abhoth", -1)
				m.record(fmt.Sprintf("secret-node-%d-%d", i, j), "secret-outcome", "secret-stage", "secret-reason", 2*time.Second)
				if j%10 == 0 {
					_ = scrapeMetrics(m)
				}
			}
		}(i)
	}
	wg.Wait()
	if len(m.totals) != 2 || m.totals[metricLabels{"unknown", "failure", "start", "internal"}] != workers*operations {
		t.Fatal("unbounded observations")
	}
	if m.pending["abhoth"] != 0 {
		t.Fatal("pending gauge lost an update")
	}
	h := m.durations[durationLabels{"abhoth", "success"}]
	if h.count != workers*operations || h.sum != workers*operations || h.buckets[4] != workers*operations || h.buckets[3] != 0 {
		t.Fatal("incorrect cumulative histogram")
	}
	exposition := scrapeMetrics(m)
	if strings.Contains(exposition, "secret-") || strings.Contains(events.String(), "secret-") {
		t.Fatal("untrusted label escaped")
	}
	var previous float64
	for _, line := range strings.Split(exposition, "\n") {
		if strings.HasPrefix(line, `realm_http_attestation_duration_seconds_bucket{component="server",node="abhoth"`) {
			var bound string
			_, _ = fmt.Sscanf(strings.Split(line, `le=`)[1], "%q", &bound)
			var value float64
			_, _ = fmt.Sscan(bound, &value)
			if value < previous {
				t.Fatal("histogram buckets are out of order")
			}
			previous = value
		}
	}
	if len(bytes.Split(bytes.TrimSpace(events.Bytes()), []byte("\n"))) != 2*workers*operations {
		t.Fatal("concurrent events lost lines")
	}
}

func TestMetricsListenerAddressPolicy(t *testing.T) {
	for _, address := range []string{":18491", "0.0.0.0:18491", "[::]:18491", "192.0.2.1:18491", "localhost:18491", "[::ffff:127.0.0.1]:18491", "[::1%lo]:18491", "127.0.0.1", "127.0.0.1:-1", "127.0.0.1:65536"} {
		if validateMetricsAddress(address) == nil {
			t.Fatalf("unsafe metrics address accepted: %s", address)
		}
	}
	for _, address := range []string{"", "127.0.0.1:18491", "[::1]:18492", "127.2.3.4:18493"} {
		if err := validateMetricsAddress(address); err != nil {
			t.Fatalf("loopback address rejected: %s", address)
		}
	}
}

func assertPortReleased(t *testing.T, address string) {
	t.Helper()
	listener, err := net.Listen("tcp", address)
	if err != nil {
		t.Fatal("metrics port remained open")
	}
	_ = listener.Close()
}

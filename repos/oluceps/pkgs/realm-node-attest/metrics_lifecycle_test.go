package nodeattest

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	configv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/service/common/config/v1"
)

func TestPluginMetricsConfigureLifecycle(t *testing.T) {
	for _, component := range []string{"agent", "server"} {
		t.Run(component, func(t *testing.T) {
			var configure func(context.Context, *configv1.ConfigureRequest) (*configv1.ConfigureResponse, error)
			var closePlugin func() error
			var listener *metricsListener
			var registry func() *metricsRegistry
			var data map[string]any
			if component == "agent" {
				p := new(AgentPlugin)
				configure, closePlugin, listener = p.Configure, p.Close, &p.listener
				registry = func() *metricsRegistry { return p.metrics }
				data = map[string]any{"trust_domain": "example.org", "fqdn": "node.example.org", "control_socket": "/unused/control.sock"}
			} else {
				p := new(ServerPlugin)
				configure, closePlugin, listener = p.Configure, p.Close, &p.listener
				registry = func() *metricsRegistry { return p.metrics }
				data = map[string]any{"trust_domain": "example.org", "port": DefaultPort, "trust_http_transport": true, "nodes": map[string]NodePolicy{"node": {FQDN: "node.example.org", Addresses: []string{fixtureIP}}}}
			}
			t.Cleanup(func() { _ = closePlugin() })
			apply := func(address string) error {
				data["metrics_address"] = address
				raw, _ := json.Marshal(data)
				ctx, cancel := context.WithCancel(context.Background())
				defer cancel()
				_, err := configure(ctx, configRequest(t, string(raw)))
				return err
			}
			if err := apply(""); err != nil || listener.listener != nil {
				t.Fatal("metrics did not default to disabled")
			}
			if err := apply("127.0.0.1:0"); err != nil {
				t.Fatal(err)
			}
			first, originalRegistry := listener.listener, registry()
			firstAddress := first.Addr().String()
			if listener.server.ReadHeaderTimeout <= 0 || listener.server.ReadTimeout <= 0 || listener.server.WriteTimeout <= 0 || listener.server.IdleTimeout <= 0 {
				t.Fatal("missing listener timeouts")
			}
			originalRegistry.events = nil
			node := "node"
			if component == "agent" {
				node = "node.example.org"
			}
			originalRegistry.record(node, "success", "attributes", "attributes_sent", time.Second)
			for range 5 {
				if err := apply("127.0.0.1:0"); err != nil || listener.listener != first || registry() != originalRegistry {
					t.Fatal("same-address Configure replaced listener or registry")
				}
			}
			client := &http.Client{Timeout: 2 * time.Second, Transport: &http.Transport{Proxy: nil, DisableKeepAlives: true}}
			for _, test := range []struct {
				method, path string
				status       int
			}{
				{http.MethodGet, "/metrics", http.StatusOK},
				{http.MethodPost, "/metrics", http.StatusMethodNotAllowed},
				{http.MethodGet, "/debug/pprof/", http.StatusNotFound},
			} {
				req, _ := http.NewRequest(test.method, "http://"+firstAddress+test.path, nil)
				response, err := client.Do(req)
				if err != nil {
					t.Fatal("Configure RPC cancellation stopped metrics")
				}
				body, _ := io.ReadAll(response.Body)
				_ = response.Body.Close()
				if response.StatusCode != test.status {
					t.Fatal("incorrect metrics route status")
				}
				if test.path == "/metrics" && test.method == http.MethodGet && (!strings.Contains(string(body), "realm_http_attestation_total") || !strings.Contains(response.Header.Get("Content-Type"), "version=0.0.4")) {
					t.Fatal("invalid scrape response")
				}
			}
			busy, err := net.Listen("tcp", "127.0.0.1:0")
			if err != nil {
				t.Fatal(err)
			}
			defer busy.Close()
			for _, address := range []string{"0.0.0.0:18491", busy.Addr().String()} {
				if apply(address) == nil || listener.listener != first {
					t.Fatal("failed Configure replaced active listener")
				}
			}
			replacement, err := net.Listen("tcp", "127.0.0.1:0")
			if err != nil {
				t.Fatal(err)
			}
			secondAddress := replacement.Addr().String()
			_ = replacement.Close()
			if err := apply(secondAddress); err != nil {
				t.Fatal(err)
			}
			assertPortReleased(t, firstAddress)
			if err := apply(""); err != nil || listener.listener != nil {
				t.Fatal("disable failed")
			}
			assertPortReleased(t, secondAddress)
			if registry().lastSuccess[node] == 0 || len(registry().totals) != 1 {
				t.Fatal("Configure discarded process history")
			}
			if err := apply("127.0.0.1:0"); err != nil {
				t.Fatal(err)
			}
			lastAddress := listener.listener.Addr().String()
			_ = closePlugin()
			_ = closePlugin()
			assertPortReleased(t, lastAddress)
		})
	}
}

type failedProofWrite struct{ *httptest.ResponseRecorder }

func (failedProofWrite) Write([]byte) (int, error) { return 0, io.ErrClosedPipe }

func TestResponderMetricsReadPublishExpiryAndCapacity(t *testing.T) {
	r, err := newResponder(ResponderConfig{FQDN: fixtureFQDN, Port: DefaultPort, ControlSocket: "/unused/control.sock"})
	if err != nil {
		t.Fatal(err)
	}
	var events bytes.Buffer
	r.metrics.events = &events
	a := fixtureAgent(t, "/unused/control.sock")
	var first challenge
	for i := range 5 {
		c, raw := fixtureChallenge(t, a)
		if i == 0 {
			first = c
		}
		proof, err := signProof(a.key, raw)
		if err != nil {
			t.Fatal(err)
		}
		req := httptest.NewRequest(http.MethodPut, "/v1/proofs/"+c.ID, bytes.NewReader(proof))
		req = req.WithContext(context.WithValue(req.Context(), controlPeerKey{}, true))
		w := httptest.NewRecorder()
		r.control(w, req)
		want := http.StatusCreated
		if i == 4 {
			want = http.StatusTooManyRequests
		}
		if w.Code != want {
			t.Fatal("unexpected control status")
		}
	}
	m := r.metrics
	if m.pending[fixtureFQDN] != 4 || m.proofs["published"] != 4 || m.lastSuccess[fixtureFQDN] != 0 {
		t.Fatal("publish counted as a completed proof read")
	}
	w := httptest.NewRecorder()
	r.public(w, httptest.NewRequest(http.MethodGet, "http://"+fixtureFQDN+":18091"+PathPrefix+first.ID, nil))
	if w.Code != http.StatusOK || m.lastSuccess[fixtureFQDN] == 0 || m.totals[metricLabels{fixtureFQDN, "success", "public", "proof_served"}] != 1 {
		t.Fatal("missing proof read metrics")
	}
	lastRead := m.lastSuccess[fixtureFQDN]
	r.public(failedProofWrite{httptest.NewRecorder()}, httptest.NewRequest(http.MethodGet, "http://"+fixtureFQDN+":18091"+PathPrefix+first.ID, nil))
	if m.lastSuccess[fixtureFQDN] != lastRead || m.totals[metricLabels{fixtureFQDN, "failure", "public", "write_failed"}] != 1 {
		t.Fatal("failed proof write counted as success")
	}
	for _, target := range []string{"http://caller-secret.example:18091" + PathPrefix + first.ID, "http://" + fixtureFQDN + ":18091" + PathPrefix + "caller-secret"} {
		r.public(httptest.NewRecorder(), httptest.NewRequest(http.MethodGet, target, nil))
	}
	deleteReq := httptest.NewRequest(http.MethodDelete, "/v1/proofs/"+first.ID, nil)
	deleteReq = deleteReq.WithContext(context.WithValue(deleteReq.Context(), controlPeerKey{}, true))
	r.control(httptest.NewRecorder(), deleteReq)
	r.control(httptest.NewRecorder(), deleteReq)
	if m.pending[fixtureFQDN] != 3 || m.proofs["deleted"] != 1 {
		t.Fatal("idempotent delete corrupted metrics")
	}
	r.now = func() time.Time { return time.Now().Add(ChallengeTTL + time.Second) }
	r.cleanup()
	r.cleanup()
	if m.pending[fixtureFQDN] != 0 || m.proofs["expired"] != 3 {
		t.Fatal("expiry did not release pending proofs")
	}
	exposition := scrapeMetrics(m)
	if !strings.Contains(exposition, `realm_http_attestation_rejections_total{component="responder",node="`+fixtureFQDN+`",stage="control",reason="capacity"} 1`) {
		t.Fatal("missing responder capacity rejection")
	}
	for _, forbidden := range []string{first.ID, first.Nonce, first.KeyThumbprint, "caller-secret", "bootstrap_jwk"} {
		if strings.Contains(exposition, forbidden) || strings.Contains(events.String(), forbidden) {
			t.Fatal("responder observation contains request data")
		}
	}
	if strings.Contains(events.String(), "attributes_sent") {
		t.Fatal("responder claimed server verification")
	}
}

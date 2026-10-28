package nodeattest

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"
)

const fixtureFQDN = "abhoth.nyaw.xyz"
const fixtureIP = "93.184.216.34"

func fixtureConfig() ServerConfig {
	return ServerConfig{TrustDomain: "nyaw.xyz", Nodes: map[string]NodePolicy{"abhoth": {FQDN: fixtureFQDN, Addresses: []string{fixtureIP}}}, Port: DefaultPort, TrustHTTPTransport: true}
}

func fixtureAgent(t *testing.T, socket string) *AgentAttempt {
	t.Helper()
	a, err := BeginAgent(AgentConfig{FQDN: fixtureFQDN, TrustDomain: "nyaw.xyz", ControlSocket: socket})
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(a.Close)
	return a
}

func fixtureServer(t *testing.T, handler http.Handler) *Server {
	t.Helper()
	endpoint := httptest.NewServer(handler)
	t.Cleanup(endpoint.Close)
	s, err := NewServer(fixtureConfig())
	if err != nil {
		t.Fatal(err)
	}
	s.dial = func(ctx context.Context, network, target string) (net.Conn, error) {
		if target != net.JoinHostPort(fixtureIP, strconv.Itoa(DefaultPort)) {
			t.Errorf("unexpected dial target %s", target)
		}
		return (&net.Dialer{}).DialContext(ctx, network, strings.TrimPrefix(endpoint.URL, "http://"))
	}
	return s
}

func fixtureChallenge(t *testing.T, a *AgentAttempt) (challenge, []byte) {
	t.Helper()
	id, _ := randomValue()
	nonce, _ := randomValue()
	c := challenge{Version: 1, ID: id, Nonce: nonce, FQDN: fixtureFQDN, TrustDomain: "nyaw.xyz", ServerID: serverID("nyaw.xyz"), KeyThumbprint: jwkFor(a.key.Public().(ed25519.PublicKey)).thumbprint(), ExpiresAt: time.Now().Add(ChallengeTTL).Unix()}
	raw, err := json.Marshal(c)
	if err != nil {
		t.Fatal(err)
	}
	return c, raw
}

func TestAttestationPublishesVerifiesAndCleansProof(t *testing.T) {
	t.Setenv("HTTP_PROXY", "http://127.0.0.1:1")
	responder, err := newResponder(ResponderConfig{FQDN: fixtureFQDN, Port: DefaultPort, ControlSocket: filepath.Join(t.TempDir(), "control.sock")})
	if err != nil {
		t.Fatal(err)
	}
	listener, err := net.Listen("unix", responder.config.ControlSocket)
	if err != nil {
		t.Fatal(err)
	}
	control := &http.Server{Handler: http.HandlerFunc(responder.control), ConnContext: func(ctx context.Context, _ net.Conn) context.Context {
		// Synthetic fixture authority; production uses kernel SO_PEERCRED instead.
		return context.WithValue(ctx, controlPeerKey{}, true)
	}}
	go func() { _ = control.Serve(listener) }()
	t.Cleanup(func() { _ = control.Close() })
	s := fixtureServer(t, http.HandlerFunc(responder.public))
	a := fixtureAgent(t, responder.config.ControlSocket)
	attempt, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(attempt.Close)
	response, err := a.Respond(context.Background(), attempt.Challenge())
	if err != nil {
		t.Fatal(err)
	}
	result, err := attempt.Verify(context.Background(), response)
	if err != nil {
		t.Fatal(err)
	}
	if result.AgentID != "spiffe://nyaw.xyz/spire/agent/http_fqdn/abhoth" || len(result.SelectorValues) != 1 || result.SelectorValues[0] != "fqdn:"+fixtureFQDN {
		t.Fatalf("unexpected identity: %+v", result)
	}
	if _, err := attempt.Verify(context.Background(), response); err == nil {
		t.Fatal("consumed session accepted again")
	}
	a.Close()
	responder.mu.Lock()
	defer responder.mu.Unlock()
	if len(responder.proofs) != 0 {
		t.Fatal("proof remained after stream cleanup")
	}
}

func TestServerRejectsUntrustedOrAmbiguousPolicy(t *testing.T) {
	cases := map[string]func(*ServerConfig){
		"untrusted HTTP": func(c *ServerConfig) { c.TrustHTTPTransport = false },
		"no nodes":       func(c *ServerConfig) { c.Nodes = nil },
		"invalid domain": func(c *ServerConfig) { c.TrustDomain = "nyaw.xyz/attacker" },
		"private destination": func(c *ServerConfig) {
			c.Nodes["abhoth"] = NodePolicy{FQDN: fixtureFQDN, Addresses: []string{"127.0.0.1"}}
		},
		"mapped destination": func(c *ServerConfig) {
			c.Nodes["abhoth"] = NodePolicy{FQDN: fixtureFQDN, Addresses: []string{"::ffff:93.184.216.34"}}
		},
		"duplicate FQDN": func(c *ServerConfig) { c.Nodes["other"] = c.Nodes["abhoth"] },
		"wildcard": func(c *ServerConfig) {
			c.Nodes["abhoth"] = NodePolicy{FQDN: "*.nyaw.xyz", Addresses: []string{fixtureIP}}
		},
	}
	for name, mutate := range cases {
		t.Run(name, func(t *testing.T) {
			config := fixtureConfig()
			mutate(&config)
			if _, err := NewServer(config); err == nil {
				t.Fatal("unsafe policy accepted")
			}
		})
	}
}

func TestUnknownFQDNAndMalformedPayloadDoNotReserveNode(t *testing.T) {
	s, err := NewServer(fixtureConfig())
	if err != nil {
		t.Fatal(err)
	}
	a := fixtureAgent(t, "/unused/control.sock")
	var payload request
	if err := json.Unmarshal(a.Payload(), &payload); err != nil {
		t.Fatal(err)
	}
	payload.FQDN = "attacker.nyaw.xyz"
	raw, _ := json.Marshal(payload)
	for _, body := range [][]byte{raw, []byte(`{}`), bytes.Repeat([]byte("x"), MaxDocumentSize+1), append(a.Payload(), []byte(` {}`)...)} {
		if _, err := s.Begin(context.Background(), body); err == nil {
			t.Fatal("invalid payload accepted")
		}
	}
	attempt, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	attempt.Close()
}

func TestProofCannotAuthorizeAnotherSession(t *testing.T) {
	a := fixtureAgent(t, "/unused/control.sock")
	var proof []byte
	s := fixtureServer(t, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(proof) }))
	first, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	proof, err = signProof(a.key, first.Challenge())
	if err != nil {
		t.Fatal(err)
	}
	first.Close()
	second, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	defer second.Close()
	response, _ := json.Marshal(ready{Version: 1, ID: second.challenge.ID})
	if _, err := second.Verify(context.Background(), response); err == nil {
		t.Fatal("cross-session replay accepted")
	}
}

func TestSwappedKeyAndModifiedSignatureFail(t *testing.T) {
	a := fixtureAgent(t, "/unused/control.sock")
	_, raw := fixtureChallenge(t, a)
	proof, err := signProof(a.key, raw)
	if err != nil {
		t.Fatal(err)
	}
	other, _, _ := ed25519.GenerateKey(rand.Reader)
	if _, err := verifyProof(proof, jwkFor(other)); err == nil {
		t.Fatal("substitute key accepted")
	}
	var doc proofDocument
	if err := json.Unmarshal(proof, &doc); err != nil {
		t.Fatal(err)
	}
	parts := strings.Split(doc.Proof, ".")
	signature, _ := base64.RawURLEncoding.DecodeString(parts[2])
	signature[0] ^= 1
	parts[2] = base64.RawURLEncoding.EncodeToString(signature)
	doc.Proof = strings.Join(parts, ".")
	proof, _ = json.Marshal(doc)
	if _, err := verifyProof(proof, jwkFor(a.key.Public().(ed25519.PublicKey))); err == nil {
		t.Fatal("modified signature accepted")
	}
}

func TestAgentRejectsChallengeForAnotherIdentityOrExpiredSession(t *testing.T) {
	for _, name := range []string{"fqdn", "domain", "server", "key", "expiry"} {
		t.Run(name, func(t *testing.T) {
			a := fixtureAgent(t, "/unused/control.sock")
			c, _ := fixtureChallenge(t, a)
			switch name {
			case "fqdn":
				c.FQDN = "other.nyaw.xyz"
			case "domain":
				c.TrustDomain = "other.xyz"
				c.ServerID = serverID(c.TrustDomain)
			case "server":
				c.ServerID = "spiffe://nyaw.xyz/service/other"
			case "key":
				c.KeyThumbprint, _ = randomValue()
			case "expiry":
				c.ExpiresAt = time.Now().Add(-time.Second).Unix()
			}
			raw, _ := json.Marshal(c)
			if _, err := a.Respond(context.Background(), raw); err == nil {
				t.Fatal("mismatched challenge accepted")
			}
		})
	}
}

func TestClaimCannotOverridePinnedRoute(t *testing.T) {
	s, err := NewServer(fixtureConfig())
	if err != nil {
		t.Fatal(err)
	}
	a := fixtureAgent(t, "/unused/control.sock")
	for _, suffix := range []string{`,"addresses":["127.0.0.1"]}`, `,"callback_url":"http://169.254.169.254/"}`, `,"port":80}`} {
		payload := append(bytes.Clone(a.Payload()[:len(a.Payload())-1]), []byte(suffix)...)
		if _, err := s.Begin(context.Background(), payload); err == nil {
			t.Fatal("claim overrode routing policy")
		}
	}
}

func TestMeshAddressIsDialedWithRegisteredHost(t *testing.T) {
	var proof []byte
	endpoint := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Host != fixtureFQDN+":18091" {
			t.Errorf("unexpected host %s", r.Host)
		}
		_, _ = w.Write(proof)
	}))
	defer endpoint.Close()
	config := fixtureConfig()
	config.Nodes["abhoth"] = NodePolicy{FQDN: fixtureFQDN, Addresses: []string{"fdcc::5"}}
	s, err := NewServer(config)
	if err != nil {
		t.Fatal(err)
	}
	s.dial = func(ctx context.Context, network, target string) (net.Conn, error) {
		if target != "[fdcc::5]:18091" {
			t.Errorf("registry pin was not used: %s", target)
		}
		return (&net.Dialer{}).DialContext(ctx, network, strings.TrimPrefix(endpoint.URL, "http://"))
	}
	a := fixtureAgent(t, "/unused/control.sock")
	attempt, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	defer attempt.Close()
	proof, err = signProof(a.key, attempt.Challenge())
	if err != nil {
		t.Fatal(err)
	}
	response, _ := json.Marshal(ready{Version: 1, ID: attempt.challenge.ID})
	if _, err := attempt.Verify(context.Background(), response); err != nil {
		t.Fatal(err)
	}
}

func TestRedirectAndOversizedEndpointResponseAreRejected(t *testing.T) {
	for _, name := range []string{"redirect", "oversized", "compressed"} {
		t.Run(name, func(t *testing.T) {
			s := fixtureServer(t, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				switch name {
				case "redirect":
					w.Header().Set("Location", "http://127.0.0.1/private")
					w.WriteHeader(http.StatusFound)
				case "oversized":
					_, _ = w.Write(bytes.Repeat([]byte("x"), MaxDocumentSize+1))
				case "compressed":
					w.Header().Set("Content-Encoding", "gzip")
					_, _ = w.Write([]byte("fixture"))
				}
			}))
			a := fixtureAgent(t, "/unused/control.sock")
			attempt, err := s.Begin(context.Background(), a.Payload())
			if err != nil {
				t.Fatal(err)
			}
			defer attempt.Close()
			response, _ := json.Marshal(ready{Version: 1, ID: attempt.challenge.ID})
			if _, err := attempt.Verify(context.Background(), response); err == nil {
				t.Fatal("invalid endpoint response accepted")
			}
		})
	}
}

func TestPendingClaimsShareOnlyGlobalCapacity(t *testing.T) {
	s, err := NewServer(fixtureConfig())
	if err != nil {
		t.Fatal(err)
	}
	a := fixtureAgent(t, "/unused/control.sock")
	var attempts []*ServerAttempt
	for range 32 {
		attempt, err := s.Begin(context.Background(), a.Payload())
		if err != nil {
			t.Fatalf("an unverified claim excluded another attempt: %v", err)
		}
		attempts = append(attempts, attempt)
		t.Cleanup(attempt.Close)
	}
	if _, err := s.Begin(context.Background(), a.Payload()); err == nil {
		t.Fatal("global pending limit exceeded")
	}
	attempts[0].Close()
	replacement, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal("closed session did not release capacity")
	}
	replacement.Close()
}

func TestOnlySuccessfulProofsConsumeNodeQuota(t *testing.T) {
	var proof atomic.Value
	s := fixtureServer(t, http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { _, _ = w.Write(proof.Load().([]byte)) }))
	a := fixtureAgent(t, "/unused/control.sock")
	proof.Store([]byte(`{}`))
	for index := range 20 {
		attempt, err := s.Begin(context.Background(), a.Payload())
		if err != nil {
			t.Fatal("unverified claims consumed node quota")
		}
		if index%2 == 0 {
			response, _ := json.Marshal(ready{Version: 1, ID: attempt.challenge.ID})
			if _, err := attempt.Verify(context.Background(), response); err == nil {
				t.Fatal("invalid proof was accepted")
			}
		}
		attempt.Close()
	}
	for index := range 7 {
		attempt, err := s.Begin(context.Background(), a.Payload())
		if err != nil {
			t.Fatal(err)
		}
		document, err := signProof(a.key, attempt.Challenge())
		if err != nil {
			t.Fatal(err)
		}
		proof.Store(document)
		response, _ := json.Marshal(ready{Version: 1, ID: attempt.challenge.ID})
		_, err = attempt.Verify(context.Background(), response)
		attempt.Close()
		if index < 6 && err != nil {
			t.Fatalf("verified proof %d rejected: %v", index, err)
		}
		if index == 6 && err == nil {
			t.Fatal("successful issuance quota exceeded")
		}
	}
}

func TestPublicEndpointCannotPublishAndControlRequiresRoot(t *testing.T) {
	r, err := newResponder(ResponderConfig{FQDN: fixtureFQDN, Port: DefaultPort, ControlSocket: "/unused/control.sock"})
	if err != nil {
		t.Fatal(err)
	}
	a := fixtureAgent(t, "/unused/control.sock")
	c, raw := fixtureChallenge(t, a)
	proof, _ := signProof(a.key, raw)
	unauthorized := httptest.NewRequest(http.MethodPut, "http://localhost/v1/proofs/"+c.ID, bytes.NewReader(proof))
	denied := httptest.NewRecorder()
	r.control(denied, unauthorized)
	if denied.Code != http.StatusForbidden {
		t.Fatal("control request without kernel peer authority accepted")
	}
	publish := unauthorized.WithContext(context.WithValue(context.Background(), controlPeerKey{}, true))
	accepted := httptest.NewRecorder()
	r.control(accepted, publish)
	if accepted.Code != http.StatusCreated {
		t.Fatalf("fixture publish failed: %d", accepted.Code)
	}
	for _, test := range []struct {
		method, target string
		status         int
	}{
		{http.MethodPut, "http://" + fixtureFQDN + ":18091" + PathPrefix + c.ID, http.StatusMethodNotAllowed},
		{http.MethodGet, "http://other.nyaw.xyz:18091" + PathPrefix + c.ID, http.StatusNotFound},
		{http.MethodGet, "http://" + fixtureFQDN + ":18091/v1/proofs/" + c.ID, http.StatusNotFound},
		{http.MethodGet, "http://" + fixtureFQDN + ":18091" + PathPrefix + c.ID + "?list=1", http.StatusNotFound},
		{http.MethodGet, "http://" + fixtureFQDN + ":18091" + PathPrefix + c.ID, http.StatusOK},
	} {
		response := httptest.NewRecorder()
		r.public(response, httptest.NewRequest(test.method, test.target, nil))
		if response.Code != test.status {
			t.Errorf("%s %s returned %d, want %d", test.method, test.target, response.Code, test.status)
		}
		if response.Header().Get("Cache-Control") != "no-store" {
			t.Error("missing cache restriction")
		}
	}
	r.now = func() time.Time { return time.Unix(c.ExpiresAt, 0) }
	response := httptest.NewRecorder()
	r.public(response, httptest.NewRequest(http.MethodGet, "http://"+fixtureFQDN+":18091"+PathPrefix+c.ID, nil))
	if response.Code != http.StatusNotFound {
		t.Fatal("expired proof remained public")
	}
}

func TestControlBodyLimit(t *testing.T) {
	r, err := newResponder(ResponderConfig{FQDN: fixtureFQDN, Port: DefaultPort, ControlSocket: "/unused/control.sock"})
	if err != nil {
		t.Fatal(err)
	}
	id, _ := randomValue()
	req := httptest.NewRequest(http.MethodPut, "http://localhost/v1/proofs/"+id, io.LimitReader(strings.NewReader(strings.Repeat("x", MaxDocumentSize+1)), MaxDocumentSize+1))
	req = req.WithContext(context.WithValue(req.Context(), controlPeerKey{}, true))
	response := httptest.NewRecorder()
	r.control(response, req)
	if response.Code != http.StatusBadRequest {
		t.Fatalf("oversized proof returned %d", response.Code)
	}
}

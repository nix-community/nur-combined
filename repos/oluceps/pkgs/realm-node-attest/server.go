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
	"net/netip"
	"strconv"
	"sync"
	"time"
)

type node struct {
	name      string
	fqdn      string
	addresses []netip.Addr
}

type Server struct {
	config  ServerConfig
	nodes   map[string]node
	mu      sync.Mutex
	active  map[string]*ServerAttempt
	recent  map[string][]time.Time
	now     func() time.Time
	dial    func(context.Context, string, string) (net.Conn, error)
	metrics *metricsRegistry
}

type ServerAttempt struct {
	server       *Server
	node         node
	request      request
	challenge    challenge
	rawChallenge []byte
	ctx          context.Context
	cancel       context.CancelFunc
	mu           sync.Mutex
	verified     bool
	closed       bool
}

func NewServer(config ServerConfig) (*Server, error) {
	if err := validateMetricsAddress(config.MetricsAddress); err != nil {
		return nil, err
	}
	if !config.TrustHTTPTransport {
		return nil, errors.New("HTTP attestation requires an explicitly trusted verification path")
	}
	if !validFQDN(config.TrustDomain) || config.Port < 1 || config.Port > 65535 || len(config.Nodes) == 0 {
		return nil, errors.New("invalid server configuration")
	}
	s := &Server{
		config: config, nodes: make(map[string]node), active: make(map[string]*ServerAttempt),
		recent: make(map[string][]time.Time), now: time.Now,
		dial: (&net.Dialer{Timeout: 3 * time.Second}).DialContext,
	}
	for name, policy := range config.Nodes {
		if !labelPattern.MatchString(name) || !validFQDN(policy.FQDN) || len(policy.Addresses) == 0 {
			return nil, errors.New("invalid node policy")
		}
		if _, exists := s.nodes[policy.FQDN]; exists {
			return nil, errors.New("duplicate node FQDN")
		}
		n := node{name: name, fqdn: policy.FQDN}
		seen := make(map[netip.Addr]bool)
		if len(policy.Addresses) > 16 {
			return nil, errors.New("too many node addresses")
		}
		for _, text := range policy.Addresses {
			address, err := netip.ParseAddr(text)
			if err != nil || !validAddress(address) {
				return nil, fmt.Errorf("node %s has an invalid pinned address", name)
			}
			if seen[address] {
				return nil, errors.New("duplicate pinned node address")
			}
			seen[address] = true
			n.addresses = append(n.addresses, address)
		}
		s.nodes[policy.FQDN] = n
	}
	return s, nil
}

func (s *Server) Begin(ctx context.Context, payload []byte) (_ *ServerAttempt, retErr error) {
	stage, reason := "payload", "invalid_payload"
	defer observeError(&retErr, &stage, &reason)
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	var request request
	if err := decodeJSON(payload, &request); err != nil {
		return nil, err
	}
	if request.Version != 1 {
		return nil, errors.New("unsupported attestation version")
	}
	reason = "unknown_node"
	n, ok := s.nodes[request.FQDN]
	if !ok {
		return nil, errors.New("FQDN is not authorized")
	}
	reason = "invalid_key"
	if _, err := request.BootstrapJWK.key(); err != nil {
		return nil, err
	}
	stage, reason = "start", "internal"
	id, err := randomValue()
	if err != nil {
		return nil, err
	}
	nonce, err := randomValue()
	if err != nil {
		return nil, err
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	if len(s.active) >= 32 {
		reason = "capacity"
		return nil, errors.New("attestation capacity reached")
	}
	now := s.now()
	c := challenge{
		Version: 1, ID: id, Nonce: nonce, FQDN: request.FQDN, TrustDomain: s.config.TrustDomain,
		ServerID: serverID(s.config.TrustDomain), KeyThumbprint: request.BootstrapJWK.thumbprint(),
		ExpiresAt: now.Add(ChallengeTTL).Unix(),
	}
	raw, err := json.Marshal(c)
	if err != nil {
		return nil, err
	}
	attemptCtx, cancel := context.WithDeadline(ctx, time.Unix(c.ExpiresAt, 0))
	attempt := &ServerAttempt{server: s, node: n, request: request, challenge: c, rawChallenge: raw, ctx: attemptCtx, cancel: cancel}
	s.active[c.ID] = attempt
	s.metrics.pendingAdd(n.name, 1)
	context.AfterFunc(attemptCtx, attempt.Close)
	return attempt, nil
}

func (a *ServerAttempt) Context() context.Context { return a.ctx }

func (a *ServerAttempt) Challenge() []byte { return bytes.Clone(a.rawChallenge) }

func (a *ServerAttempt) Verify(ctx context.Context, response []byte) (_ *Result, retErr error) {
	stage, reason := "response", "invalid_response"
	defer observeError(&retErr, &stage, &reason)
	a.mu.Lock()
	if a.closed || a.verified {
		reason = "session_ended"
		a.mu.Unlock()
		return nil, errors.New("attestation is not pending")
	}
	a.verified = true
	a.mu.Unlock()
	var ready ready
	if err := decodeJSON(response, &ready); err != nil {
		return nil, err
	}
	if ready.Version != 1 || ready.ID != a.challenge.ID {
		return nil, errors.New("unexpected challenge response")
	}
	if a.server.now().Unix() >= a.challenge.ExpiresAt {
		reason = "expired"
		return nil, errors.New("challenge expired")
	}
	fetchCtx, cancel := context.WithTimeout(a.ctx, 5*time.Second)
	defer cancel()
	stop := context.AfterFunc(ctx, cancel)
	defer stop()
	stage, reason = "fetch", "endpoint_failed"
	proof, err := a.fetch(fetchCtx)
	if err != nil {
		return nil, err
	}
	stage, reason = "verify", "invalid_proof"
	payload, err := verifyProof(proof, a.request.BootstrapJWK)
	if err != nil {
		return nil, err
	}
	if !bytes.Equal(payload, a.rawChallenge) {
		return nil, errors.New("proof is not for this attestation session")
	}
	a.mu.Lock()
	defer a.mu.Unlock()
	if a.closed || a.server.now().Unix() >= a.challenge.ExpiresAt || fetchCtx.Err() != nil {
		reason = "session_ended"
		return nil, errors.New("attestation session ended")
	}
	// A verified endpoint consumes the quota before the adapter sends attributes.
	// This is a plugin verification limit. It does not count issued SVIDs.
	stage, reason = "quota", "rate_limit"
	if err := a.server.chargeSuccess(a.node.name); err != nil {
		return nil, err
	}
	return &Result{
		AgentID:        "spiffe://" + a.server.config.TrustDomain + "/spire/agent/" + PluginName + "/" + a.node.name,
		SelectorValues: []string{"fqdn:" + a.node.fqdn},
	}, nil
}

func (a *ServerAttempt) Close() {
	a.mu.Lock()
	if a.closed {
		a.mu.Unlock()
		return
	}
	a.closed = true
	a.cancel()
	a.mu.Unlock()
	a.server.mu.Lock()
	if a.server.active[a.challenge.ID] == a {
		delete(a.server.active, a.challenge.ID)
		a.server.metrics.pendingAdd(a.node.name, -1)
	}
	a.server.mu.Unlock()
}

func (s *Server) chargeSuccess(name string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := s.now()
	recent := s.recent[name][:0]
	for _, previous := range s.recent[name] {
		if previous.After(now.Add(-time.Minute)) {
			recent = append(recent, previous)
		}
	}
	s.recent[name] = recent
	if len(recent) >= 6 {
		return errors.New("node attestation rate exceeded")
	}
	s.recent[name] = append(recent, now)
	return nil
}

func (a *ServerAttempt) fetch(ctx context.Context) ([]byte, error) {
	// The operator's registry supplies the destinations. DNS and hosts files cannot redirect this fetch.
	addresses := a.node.addresses
	host := net.JoinHostPort(a.node.fqdn, strconv.Itoa(a.server.config.Port))
	url := "http://" + host + PathPrefix + a.challenge.ID
	for _, address := range addresses {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		// Dial only the validated literal address, never the URL hostname.
		target := net.JoinHostPort(address.String(), strconv.Itoa(a.server.config.Port))
		transport := &http.Transport{
			Proxy: nil, DisableKeepAlives: true, DisableCompression: true,
			MaxResponseHeaderBytes: MaxDocumentSize,
			DialContext:            func(ctx context.Context, _, _ string) (net.Conn, error) { return a.server.dial(ctx, "tcp", target) },
		}
		client := &http.Client{Transport: transport, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
		if err != nil {
			transport.CloseIdleConnections()
			return nil, err
		}
		req.Header.Set("Accept", "application/json")
		response, err := client.Do(req)
		if err != nil {
			transport.CloseIdleConnections()
			continue
		}
		body, readErr := io.ReadAll(io.LimitReader(response.Body, MaxDocumentSize+1))
		_ = response.Body.Close()
		transport.CloseIdleConnections()
		if response.StatusCode != http.StatusOK || readErr != nil || len(body) > MaxDocumentSize || response.Header.Get("Content-Encoding") != "" {
			return nil, errors.New("HTTP endpoint returned an invalid response")
		}
		return body, nil
	}
	return nil, errors.New("HTTP endpoint unavailable")
}

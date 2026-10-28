package nodeattest

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"path/filepath"
	"sync"
	"time"
)

type AgentAttempt struct {
	mu        sync.Mutex
	config    AgentConfig
	key       ed25519.PrivateKey
	payload   []byte
	published string
	responded bool
	closed    bool
}

func validateAgentConfig(config AgentConfig) error {
	if err := validateMetricsAddress(config.MetricsAddress); err != nil {
		return err
	}
	if !validFQDN(config.FQDN) || !validFQDN(config.TrustDomain) || !filepath.IsAbs(config.ControlSocket) {
		return errors.New("invalid agent configuration")
	}
	return nil
}

func BeginAgent(config AgentConfig) (*AgentAttempt, error) {
	if err := validateAgentConfig(config); err != nil {
		return nil, err
	}
	public, private, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, err
	}
	payload, err := json.Marshal(request{Version: 1, FQDN: config.FQDN, BootstrapJWK: jwkFor(public)})
	if err != nil {
		return nil, err
	}
	return &AgentAttempt{config: config, key: private, payload: payload}, nil
}

func (a *AgentAttempt) Payload() []byte { return bytes.Clone(a.payload) }

func (a *AgentAttempt) Respond(ctx context.Context, rawChallenge []byte) (_ []byte, retErr error) {
	stage, reason := "challenge", "invalid_challenge"
	defer observeError(&retErr, &stage, &reason)
	a.mu.Lock()
	defer a.mu.Unlock()
	if a.closed || a.responded {
		return nil, errors.New("agent attempt is not pending")
	}
	a.responded = true
	var c challenge
	if err := decodeJSON(rawChallenge, &c); err != nil {
		return nil, err
	}
	if err := validateChallenge(c, time.Now()); err != nil {
		return nil, err
	}
	if c.FQDN != a.config.FQDN || c.TrustDomain != a.config.TrustDomain || c.ServerID != serverID(a.config.TrustDomain) ||
		c.KeyThumbprint != jwkFor(a.key.Public().(ed25519.PublicKey)).thumbprint() {
		return nil, errors.New("challenge does not match agent attempt")
	}
	proof, err := signProof(a.key, rawChallenge)
	if err != nil {
		return nil, err
	}
	// Record the ID before publishing so a lost HTTP response still gets cleanup.
	a.published = c.ID
	stage, reason = "publish", "publish_failed"
	if err := controlRequest(ctx, a.config.ControlSocket, http.MethodPut, c.ID, proof); err != nil {
		return nil, fmt.Errorf("publish challenge: %w", err)
	}
	return json.Marshal(ready{Version: 1, ID: c.ID})
}

func (a *AgentAttempt) Close() {
	a.mu.Lock()
	defer a.mu.Unlock()
	if a.closed {
		return
	}
	a.closed = true
	if a.published != "" {
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		_ = controlRequest(ctx, a.config.ControlSocket, http.MethodDelete, a.published, nil)
		cancel()
	}
	clear(a.key)
	a.key = nil
}

func controlRequest(ctx context.Context, socket, method, id string, body []byte) error {
	ctx, cancel := context.WithTimeout(ctx, 2*time.Second)
	defer cancel()
	transport := &http.Transport{
		Proxy:             nil,
		DisableKeepAlives: true,
		DialContext: func(ctx context.Context, _, _ string) (net.Conn, error) {
			return (&net.Dialer{}).DialContext(ctx, "unix", socket)
		},
	}
	defer transport.CloseIdleConnections()
	client := &http.Client{Transport: transport, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	req, err := http.NewRequestWithContext(ctx, method, "http://localhost/v1/proofs/"+id, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	response, err := client.Do(req)
	if err != nil {
		return errors.New("control endpoint unavailable")
	}
	defer response.Body.Close()
	_, _ = io.Copy(io.Discard, io.LimitReader(response.Body, 1024))
	if (method == http.MethodPut && response.StatusCode != http.StatusCreated) ||
		(method == http.MethodDelete && response.StatusCode != http.StatusNoContent && response.StatusCode != http.StatusNotFound) {
		return errors.New("control endpoint rejected operation")
	}
	return nil
}

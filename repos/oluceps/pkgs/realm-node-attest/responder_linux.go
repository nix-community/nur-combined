//go:build linux

package nodeattest

import (
	"bytes"
	"context"
	"errors"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"time"
)

type ResponderConfig struct {
	FQDN           string
	Port           int
	ControlSocket  string
	MetricsAddress string
}

type storedProof struct {
	body      []byte
	expiresAt int64
}

type responder struct {
	config  ResponderConfig
	mu      sync.Mutex
	proofs  map[string]storedProof
	now     func() time.Time
	metrics *metricsRegistry
}

type controlPeerKey struct{}

func newResponder(config ResponderConfig) (*responder, error) {
	if err := validateMetricsAddress(config.MetricsAddress); err != nil {
		return nil, err
	}
	if !validFQDN(config.FQDN) || config.Port < 1 || config.Port > 65535 || !filepath.IsAbs(config.ControlSocket) {
		return nil, errors.New("invalid responder configuration")
	}
	metrics := newMetrics("responder")
	metrics.register(config.FQDN)
	metrics.capacity = 4
	return &responder{config: config, proofs: make(map[string]storedProof), now: time.Now, metrics: metrics}, nil
}

func proofID(path, prefix string) (string, bool) {
	if !strings.HasPrefix(path, prefix) {
		return "", false
	}
	id := strings.TrimPrefix(path, prefix)
	return id, validRandom(id)
}

func (r *responder) cleanup() {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.expireLocked()
}

func (r *responder) expireLocked() {
	for id, proof := range r.proofs {
		if proof.expiresAt <= r.now().Unix() {
			delete(r.proofs, id)
			r.metrics.pendingAdd(r.config.FQDN, -1)
			r.metrics.proof("expired")
		}
	}
}

func (r *responder) public(w http.ResponseWriter, request *http.Request) {
	start := time.Now()
	outcome, reason := "failure", "invalid_request"
	defer func() { r.metrics.record(r.config.FQDN, outcome, "public", reason, time.Since(start)) }()
	w.Header().Set("Cache-Control", "no-store")
	if request.Method != http.MethodGet {
		reason = "method"
		w.Header().Set("Allow", "GET")
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if request.Host != net.JoinHostPort(r.config.FQDN, strconv.Itoa(r.config.Port)) || request.URL.RawQuery != "" ||
		request.URL.EscapedPath() != request.URL.Path || request.ContentLength > 0 || len(request.TransferEncoding) != 0 {
		http.NotFound(w, request)
		return
	}
	id, valid := proofID(request.URL.Path, PathPrefix)
	if !valid {
		http.NotFound(w, request)
		return
	}
	r.mu.Lock()
	r.expireLocked()
	proof, exists := r.proofs[id]
	r.mu.Unlock()
	if !exists {
		reason = "not_found"
		http.NotFound(w, request)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(http.StatusOK)
	n, err := w.Write(proof.body)
	if err != nil || n != len(proof.body) {
		reason = "write_failed"
		return
	}
	outcome, reason = "success", "proof_served"
}

func (r *responder) control(w http.ResponseWriter, request *http.Request) {
	start := time.Now()
	outcome, reason := "failure", "invalid_request"
	defer func() { r.metrics.record(r.config.FQDN, outcome, "control", reason, time.Since(start)) }()
	if request.Context().Value(controlPeerKey{}) != true {
		reason = "peer_denied"
		http.Error(w, "root peer required", http.StatusForbidden)
		return
	}
	if request.URL.RawQuery != "" || request.URL.EscapedPath() != request.URL.Path {
		http.NotFound(w, request)
		return
	}
	id, valid := proofID(request.URL.Path, "/v1/proofs/")
	if !valid {
		http.NotFound(w, request)
		return
	}
	switch request.Method {
	case http.MethodPut:
		body, err := io.ReadAll(http.MaxBytesReader(w, request.Body, MaxDocumentSize))
		if err != nil {
			reason = "invalid_size"
			http.Error(w, "invalid proof size", http.StatusBadRequest)
			return
		}
		c, err := parseProof(body, r.config.FQDN, r.now())
		if err != nil || c.ID != id {
			reason = "invalid_proof"
			http.Error(w, "invalid proof", http.StatusBadRequest)
			return
		}
		r.mu.Lock()
		r.expireLocked()
		_, exists := r.proofs[id]
		if !exists && len(r.proofs) >= 4 {
			reason = "capacity"
			r.mu.Unlock()
			http.Error(w, "proof capacity reached", http.StatusTooManyRequests)
			return
		}
		r.proofs[id] = storedProof{body: bytes.Clone(body), expiresAt: c.ExpiresAt}
		if !exists {
			r.metrics.pendingAdd(r.config.FQDN, 1)
		}
		r.metrics.proof("published")
		r.mu.Unlock()
		w.WriteHeader(http.StatusCreated)
		outcome, reason = "success", "proof_published"
	case http.MethodDelete:
		r.mu.Lock()
		if _, exists := r.proofs[id]; exists {
			delete(r.proofs, id)
			r.metrics.pendingAdd(r.config.FQDN, -1)
			r.metrics.proof("deleted")
		}
		r.mu.Unlock()
		w.WriteHeader(http.StatusNoContent)
		outcome, reason = "success", "proof_deleted"
	default:
		reason = "method"
		w.Header().Set("Allow", "PUT, DELETE")
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
	}
}

func rootPeer(connection net.Conn) bool {
	if limited, ok := connection.(*limitedConnection); ok {
		connection = limited.Conn
	}
	unix, ok := connection.(*net.UnixConn)
	if !ok {
		return false
	}
	raw, err := unix.SyscallConn()
	if err != nil {
		return false
	}
	var credentials *syscall.Ucred
	var credentialErr error
	if err := raw.Control(func(fd uintptr) {
		credentials, credentialErr = syscall.GetsockoptUcred(int(fd), syscall.SOL_SOCKET, syscall.SO_PEERCRED)
	}); err != nil {
		return false
	}
	return credentialErr == nil && credentials != nil && credentials.Uid == 0
}

func RunResponder(ctx context.Context, config ResponderConfig) error {
	responder, err := newResponder(config)
	if err != nil {
		return err
	}
	listeners, err := responderListeners(config)
	if err != nil {
		return err
	}
	defer func() {
		for _, listener := range listeners {
			_ = listener.Close()
		}
	}()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	var metrics metricsListener
	if err := metrics.configure(config.MetricsAddress, responder.metrics); err != nil {
		return err
	}
	defer metrics.close()
	var servers []*http.Server
	errorsChannel := make(chan error, len(listeners))
	for name, listener := range listeners {
		handler := http.HandlerFunc(responder.public)
		server := &http.Server{
			ReadHeaderTimeout: 2 * time.Second, ReadTimeout: 5 * time.Second, WriteTimeout: 5 * time.Second,
			IdleTimeout: time.Second, MaxHeaderBytes: MaxDocumentSize,
			ErrorLog: log.New(io.Discard, "", 0),
		}
		if name == "control" {
			handler = responder.control
			server.ConnContext = func(ctx context.Context, connection net.Conn) context.Context {
				return context.WithValue(ctx, controlPeerKey{}, rootPeer(connection))
			}
		}
		server.Handler = handler
		servers = append(servers, server)
		go func() { errorsChannel <- server.Serve(limitListener(listener, 32)) }()
	}
	go func() {
		ticker := time.NewTicker(time.Second)
		defer ticker.Stop()
		for {
			select {
			case <-ticker.C:
				responder.cleanup()
			case <-ctx.Done():
				return
			}
		}
	}()
	var serveErr error
	select {
	case <-ctx.Done():
	case serveErr = <-errorsChannel:
		if errors.Is(serveErr, http.ErrServerClosed) {
			serveErr = nil
		}
	}
	cancel()
	for _, server := range servers {
		_ = server.Close()
	}
	return serveErr
}

func responderListeners(config ResponderConfig) (map[string]net.Listener, error) {
	if os.Getenv("LISTEN_FDS") != "" {
		return activatedListeners(config)
	}
	listeners := make(map[string]net.Listener)
	fail := func(err error) (map[string]net.Listener, error) {
		for _, listener := range listeners {
			_ = listener.Close()
		}
		return nil, err
	}
	if err := os.MkdirAll(filepath.Dir(config.ControlSocket), 0o700); err != nil {
		return fail(err)
	}
	control, err := net.Listen("unix", config.ControlSocket)
	if err != nil {
		return fail(err)
	}
	listeners["control"] = control
	if err := os.Chmod(config.ControlSocket, 0o600); err != nil {
		return fail(err)
	}
	for name, network := range map[string]string{"http4": "tcp4", "http6": "tcp6"} {
		address := "0.0.0.0"
		if network == "tcp6" {
			address = "::"
		}
		listener, err := net.Listen(network, net.JoinHostPort(address, strconv.Itoa(config.Port)))
		if err != nil {
			return fail(err)
		}
		listeners[name] = listener
	}
	return listeners, nil
}

func activatedListeners(config ResponderConfig) (map[string]net.Listener, error) {
	pid, err := strconv.Atoi(os.Getenv("LISTEN_PID"))
	if err != nil || pid != os.Getpid() {
		return nil, errors.New("invalid activation PID")
	}
	count, err := strconv.Atoi(os.Getenv("LISTEN_FDS"))
	names := strings.Split(os.Getenv("LISTEN_FDNAMES"), ":")
	if err != nil || count < 2 || count > 3 || len(names) != count {
		return nil, errors.New("expected a control socket and one or two HTTP sockets")
	}
	listeners := make(map[string]net.Listener)
	fail := func(err error) (map[string]net.Listener, error) {
		for _, listener := range listeners {
			_ = listener.Close()
		}
		return nil, err
	}
	for index, name := range names {
		if name != "control" && name != "http4" && name != "http6" {
			return fail(errors.New("unknown activation socket"))
		}
		if listeners[name] != nil {
			return fail(errors.New("duplicate activation socket"))
		}
		file := os.NewFile(uintptr(3+index), name)
		listener, err := net.FileListener(file)
		_ = file.Close()
		if err != nil {
			return fail(err)
		}
		listeners[name] = listener
		if name == "control" {
			unix, ok := listener.Addr().(*net.UnixAddr)
			if !ok || unix.Name != config.ControlSocket {
				return fail(errors.New("unexpected control listener"))
			}
		} else {
			tcp, ok := listener.Addr().(*net.TCPAddr)
			if !ok || tcp.Port != config.Port || (name == "http4") != (tcp.IP.To4() != nil) {
				return fail(errors.New("unexpected HTTP listener"))
			}
		}
	}
	if listeners["control"] == nil || (listeners["http4"] == nil && listeners["http6"] == nil) {
		return fail(errors.New("activation requires control and HTTP listeners"))
	}
	return listeners, nil
}

type limitedListener struct {
	net.Listener
	permits chan struct{}
	done    chan struct{}
	once    sync.Once
}

type limitedConnection struct {
	net.Conn
	once    sync.Once
	release func()
}

func limitListener(listener net.Listener, count int) net.Listener {
	return &limitedListener{Listener: listener, permits: make(chan struct{}, count), done: make(chan struct{})}
}

func (l *limitedListener) Accept() (net.Conn, error) {
	select {
	case l.permits <- struct{}{}:
	case <-l.done:
		return nil, net.ErrClosed
	}
	connection, err := l.Listener.Accept()
	if err != nil {
		<-l.permits
		return nil, err
	}
	return &limitedConnection{Conn: connection, release: func() { <-l.permits }}, nil
}

func (l *limitedListener) Close() error {
	l.once.Do(func() { close(l.done) })
	return l.Listener.Close()
}

func (c *limitedConnection) Close() error {
	err := c.Conn.Close()
	c.once.Do(c.release)
	return err
}

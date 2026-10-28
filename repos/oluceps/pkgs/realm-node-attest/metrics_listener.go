package nodeattest

import (
	"context"
	"errors"
	"io"
	"log"
	"net"
	"net/http"
	"net/netip"
	"strconv"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Configure holds the plugin lock while it replaces this listener.
// The Configure RPC context ends after that RPC, so it cannot own the listener.
type metricsListener struct {
	address  string
	listener net.Listener
	server   *http.Server
}

func validateMetricsAddress(address string) error {
	if address == "" {
		return nil
	}
	host, port, err := net.SplitHostPort(address)
	if err != nil {
		return errors.New("invalid metrics address")
	}
	ip, err := netip.ParseAddr(host)
	if err != nil || !ip.IsLoopback() || ip.Zone() != "" || ip.Is4In6() {
		return errors.New("metrics address must use a literal loopback IP")
	}
	number, err := strconv.Atoi(port)
	if err != nil || number < 0 || number > 65535 {
		return errors.New("invalid metrics port")
	}
	return nil
}

func (m *metricsListener) configure(address string, handler http.Handler) error {
	if err := validateMetricsAddress(address); err != nil {
		return err
	}
	if address == m.address {
		return nil
	}
	if address == "" {
		return m.close()
	}
	listener, err := net.Listen("tcp", address)
	if err != nil {
		return errors.New("cannot listen on metrics address")
	}
	mux := http.NewServeMux()
	mux.Handle("/metrics", handler)
	server := &http.Server{
		Handler: mux, ReadHeaderTimeout: 2 * time.Second, ReadTimeout: 5 * time.Second,
		WriteTimeout: 5 * time.Second, IdleTimeout: 5 * time.Second, MaxHeaderBytes: MaxDocumentSize,
		ErrorLog: log.New(io.Discard, "", 0),
	}
	// Bind first. A failed replacement leaves the previous configuration intact.
	_ = m.close()
	m.address, m.listener, m.server = address, listener, server
	go func() { _ = server.Serve(limitListener(listener, 16)) }()
	return nil
}

func (m *metricsListener) close() error {
	if m.server == nil {
		return nil
	}
	// Close also covers an early close before Serve registers its listener.
	err := m.server.Close()
	_ = m.listener.Close()
	m.address, m.listener, m.server = "", nil, nil
	return err
}

type observationError struct {
	err           error
	stage, reason string
}

func (e *observationError) Error() string { return e.err.Error() }
func (e *observationError) Unwrap() error { return e.err }

func classifyError(ctx context.Context, err error, stage, reason string) (string, string) {
	var classified *observationError
	if errors.As(err, &classified) {
		stage, reason = classified.stage, classified.reason
	}
	if errors.Is(err, context.Canceled) || errors.Is(ctx.Err(), context.Canceled) || status.Code(err) == codes.Canceled {
		return stage, "canceled"
	}
	if errors.Is(err, context.DeadlineExceeded) || errors.Is(ctx.Err(), context.DeadlineExceeded) || status.Code(err) == codes.DeadlineExceeded {
		return stage, "deadline"
	}
	return stage, reason
}

func observeError(err *error, stage, reason *string) {
	if *err != nil {
		*err = &observationError{err: *err, stage: *stage, reason: *reason}
	}
}

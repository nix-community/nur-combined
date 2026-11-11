package nodeattest

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"sort"
	"syscall"
	"time"
)

// hclogTimestampLayout matches hashicorp/go-plugin's parseJSON layout so SPIRE
// forwards structured plugin stderr events instead of dropping them to debug.
const hclogTimestampLayout = "2006-01-02T15:04:05.000000Z07:00"

type controlError struct {
	message string
	method  string
	phase   string
	status  int
	err     error
}

func (e *controlError) Error() string { return e.message }
func (e *controlError) Unwrap() error { return e.err }

func (m *metricsRegistry) emitStructuredEvent(now time.Time, level, message string, fields map[string]any) {
	if m == nil {
		return
	}
	m.mu.Lock()
	writer := m.events
	logger := m.logger
	m.mu.Unlock()
	// Inside SPIRE plugins, go-plugin replaces os.Stderr after starting the SDK logger.
	// When using the default stderr sink and SPIRE supplied an hclog.Logger, emit through
	// that logger so events reach SPIRE instead of being piped to SyncStderr (discard).
	if logger != nil && writer == os.Stderr {
		keys := make([]string, 0, len(fields))
		for k := range fields {
			keys = append(keys, k)
		}
		sort.Strings(keys)
		args := make([]any, 0, len(keys)*2)
		for _, k := range keys {
			args = append(args, k, fields[k])
		}
		if level == "warn" {
			logger.Warn(message, args...)
		} else {
			logger.Info(message, args...)
		}
		return
	}
	if writer == nil {
		return
	}
	payload := make(map[string]any, len(fields)+3)
	for k, v := range fields {
		payload[k] = v
	}
	payload["@timestamp"] = now.UTC().Format(hclogTimestampLayout)
	payload["@level"] = level
	payload["@message"] = message
	data, _ := json.Marshal(payload)
	eventMu.Lock()
	_, _ = writer.Write(append(data, '\n'))
	eventMu.Unlock()
}

func (m *metricsRegistry) emitDiagnostic(node, message string, extra map[string]any, err error) {
	if m == nil {
		return
	}
	m.mu.Lock()
	node = m.nodeLocked(node)
	component := m.component
	m.mu.Unlock()
	fields := map[string]any{
		"component": component,
		"node":      node,
	}
	for k, v := range extra {
		fields[k] = v
	}
	if err != nil {
		// Unwrap url.Error without formatting its URL (which can contain challenge IDs or socket paths).
		var requestError *url.Error
		if errors.As(err, &requestError) {
			err = requestError.Err
		}
		fields["error_type"] = fmt.Sprintf("%T", err)
		fields["error"] = safeFetchError(err)
		var operation *net.OpError
		if errors.As(err, &operation) {
			fields["network_operation"] = operation.Op
			fields["network"] = operation.Net
		}
	}
	m.emitStructuredEvent(time.Now(), "warn", message, fields)
}

// fetchFailure logs only configured destinations and explicitly safe error details.
func (m *metricsRegistry) fetchFailure(node, target, phase string, status, responseBytes int, started time.Time, err error) {
	m.emitDiagnostic(node, "realm_http_attestation_fetch_failed", map[string]any{
		"target":           target,
		"stage":            "fetch",
		"phase":            phase,
		"http_status":      status,
		"response_bytes":   responseBytes,
		"duration_seconds": max(0, time.Since(started).Seconds()),
	}, err)
}

func (m *metricsRegistry) controlFailure(node string, err error) {
	var ce *controlError
	if !errors.As(err, &ce) {
		return
	}
	m.emitDiagnostic(node, "realm_http_attestation_control_failed", map[string]any{
		"stage":       "publish",
		"method":      ce.method,
		"phase":       ce.phase,
		"http_status": ce.status,
	}, ce.err)
}

func (m *metricsRegistry) responderFailure(node, stage, reason, phase string, status int, err error) {
	m.emitDiagnostic(node, "realm_http_attestation_responder_failed", map[string]any{
		"stage":       stage,
		"reason":      reason,
		"phase":       phase,
		"http_status": status,
	}, err)
}

func safeFetchError(err error) string {
	switch {
	case errors.Is(err, context.Canceled):
		return "context canceled"
	case errors.Is(err, context.DeadlineExceeded):
		return "context deadline exceeded"
	case errors.Is(err, io.ErrUnexpectedEOF):
		return "unexpected EOF"
	case errors.Is(err, io.EOF):
		return "EOF"
	}
	var maxBytes *http.MaxBytesError
	if errors.As(err, &maxBytes) {
		return "request body too large"
	}
	var errno syscall.Errno
	if errors.As(err, &errno) {
		return errno.Error()
	}
	var networkError net.Error
	if errors.As(err, &networkError) && networkError.Timeout() {
		return "network timeout"
	}
	return "transport or response read failed (untrusted error text omitted)"
}

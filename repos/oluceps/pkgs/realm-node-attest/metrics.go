package nodeattest

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"sort"
	"strconv"
	"sync"
	"time"
)

// These values are the complete vocabulary for metric labels and events.
var stages = map[string]bool{
	"start": true, "payload": true, "challenge": true, "publish": true,
	"response": true, "fetch": true, "verify": true,
	"quota": true, "attributes": true, "public": true, "control": true,
}
var reasons = map[string]bool{
	"internal": true, "not_configured": true, "invalid_payload": true, "unknown_node": true,
	"invalid_key": true, "capacity": true, "stream_error": true, "no_challenge": true,
	"invalid_challenge": true, "publish_failed": true, "invalid_response": true,
	"expired": true, "endpoint_failed": true, "invalid_proof": true, "session_ended": true,
	"rate_limit": true, "invalid_result": true, "attributes_sent": true, "proof_submitted": true,
	"canceled": true, "deadline": true,
	"method": true, "invalid_request": true, "not_found": true, "peer_denied": true,
	"invalid_size": true, "proof_served": true, "proof_published": true, "proof_deleted": true,
	"write_failed": true,
}
var outcomes = map[string]bool{"success": true, "failure": true, "skipped": true}
var durationBuckets = [...]float64{0.01, 0.05, 0.1, 0.5, 1, 2.5, 5, 10, 30, 60, 120}

type metricLabels struct{ node, outcome, stage, reason string }
type durationLabels struct{ node, outcome string }
type durationMetric struct {
	count   uint64
	sum     float64
	buckets [len(durationBuckets)]uint64
}

// A registry lives for one process plugin instance, including Configure calls.
// Only configuration can admit node labels. Request fields cannot add labels.
type metricsRegistry struct {
	mu          sync.Mutex
	component   string
	nodes       map[string]bool
	totals      map[metricLabels]uint64
	durations   map[durationLabels]durationMetric
	lastSuccess map[string]float64
	pending     map[string]int
	capacity    int
	proofs      map[string]uint64
	events      io.Writer
}

func newMetrics(component string) *metricsRegistry {
	if component != "agent" && component != "server" && component != "responder" {
		panic("invalid metrics component")
	}
	return &metricsRegistry{component: component, nodes: map[string]bool{"unknown": true},
		totals: make(map[metricLabels]uint64), durations: make(map[durationLabels]durationMetric),
		lastSuccess: make(map[string]float64), pending: make(map[string]int), proofs: make(map[string]uint64), events: os.Stderr}
}

func (m *metricsRegistry) register(nodes ...string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, node := range nodes {
		m.nodes[node] = true
		if _, ok := m.lastSuccess[node]; !ok {
			m.lastSuccess[node] = 0
			m.pending[node] = 0
		}
	}
}

func (m *metricsRegistry) nodeLocked(node string) string {
	if m.nodes[node] {
		return node
	}
	return "unknown"
}

func bounded(value string, allowed map[string]bool, fallback string) string {
	if allowed[value] {
		return value
	}
	return fallback
}

func (m *metricsRegistry) pendingAdd(node string, delta int) {
	if m == nil {
		return
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	m.pending[m.nodeLocked(node)] += delta
}

func (m *metricsRegistry) proof(action string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	// Callers supply constants, and this guard also bounds future call sites.
	if action == "published" || action == "deleted" || action == "expired" {
		m.proofs[action]++
	}
}

var eventMu sync.Mutex

func (m *metricsRegistry) record(node, outcome, stage, reason string, duration time.Duration) {
	if m == nil {
		return
	}
	m.mu.Lock()
	node = m.nodeLocked(node)
	outcome = bounded(outcome, outcomes, "failure")
	stage = bounded(stage, stages, "start")
	reason = bounded(reason, reasons, "internal")
	m.totals[metricLabels{node, outcome, stage, reason}]++
	key := durationLabels{node, outcome}
	h := m.durations[key]
	seconds := max(0, duration.Seconds())
	h.count++
	h.sum += seconds
	for i, bound := range durationBuckets {
		if seconds <= bound {
			h.buckets[i]++
		}
	}
	m.durations[key] = h
	now := time.Now()
	if outcome == "success" && (m.component != "responder" || reason == "proof_served") {
		m.lastSuccess[node] = float64(now.UnixNano()) / 1e9
	}
	writer := m.events
	m.mu.Unlock()
	level := "info"
	if outcome == "failure" {
		level = "warn"
	}
	// Match the SDK's stderr JSON envelope. Never attach errors or request data.
	data, _ := json.Marshal(map[string]any{
		"@timestamp": now.UTC().Format(time.RFC3339Nano), "@level": level, "@message": "realm_http_attestation",
		"component": m.component, "node": node, "outcome": outcome, "stage": stage, "reason": reason, "duration_seconds": seconds,
	})
	if writer != nil {
		eventMu.Lock()
		_, _ = writer.Write(append(data, '\n'))
		eventMu.Unlock()
	}
}

func (m *metricsRegistry) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/metrics" {
		http.NotFound(w, r)
		return
	}
	if r.Method != http.MethodGet {
		w.Header().Set("Allow", "GET")
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	m.mu.Lock()
	var b bytes.Buffer
	fmt.Fprintln(&b, "# HELP realm_http_attestation_total Completed local operations. Success does not assert SVID issuance.")
	fmt.Fprintln(&b, "# TYPE realm_http_attestation_total counter")
	var lines []string
	for k, count := range m.totals {
		labels := fmt.Sprintf("component=%q,node=%q,outcome=%q,stage=%q,reason=%q", m.component, k.node, k.outcome, k.stage, k.reason)
		lines = append(lines, fmt.Sprintf("realm_http_attestation_total{%s} %d\n", labels, count))
	}
	sort.Strings(lines)
	for _, line := range lines {
		b.WriteString(line)
	}
	fmt.Fprintln(&b, "# HELP realm_http_attestation_duration_seconds Duration of completed local operations.")
	fmt.Fprintln(&b, "# TYPE realm_http_attestation_duration_seconds histogram")
	keys := make([]durationLabels, 0, len(m.durations))
	for key := range m.durations {
		keys = append(keys, key)
	}
	sort.Slice(keys, func(i, j int) bool {
		if keys[i].node != keys[j].node {
			return keys[i].node < keys[j].node
		}
		return keys[i].outcome < keys[j].outcome
	})
	for _, k := range keys {
		h := m.durations[k]
		labels := fmt.Sprintf("component=%q,node=%q,outcome=%q", m.component, k.node, k.outcome)
		for i, bound := range durationBuckets {
			fmt.Fprintf(&b, "realm_http_attestation_duration_seconds_bucket{%s,le=%q} %d\n", labels, strconv.FormatFloat(bound, 'g', -1, 64), h.buckets[i])
		}
		fmt.Fprintf(&b, "realm_http_attestation_duration_seconds_bucket{%s,le=\"+Inf\"} %d\nrealm_http_attestation_duration_seconds_sum{%s} %g\nrealm_http_attestation_duration_seconds_count{%s} %d\n", labels, h.count, labels, h.sum, labels, h.count)
	}
	fmt.Fprintln(&b, "# HELP realm_http_attestation_last_success_timestamp_seconds Last local proof success in this process. Zero means none.")
	fmt.Fprintln(&b, "# TYPE realm_http_attestation_last_success_timestamp_seconds gauge")
	nodes := make([]string, 0, len(m.nodes))
	for node := range m.nodes {
		nodes = append(nodes, node)
	}
	sort.Strings(nodes)
	for _, node := range nodes {
		fmt.Fprintf(&b, "realm_http_attestation_last_success_timestamp_seconds{component=%q,node=%q} %g\n", m.component, node, m.lastSuccess[node])
	}
	fmt.Fprintln(&b, "# HELP realm_http_attestation_pending Current local attempts or stored responder proofs.")
	fmt.Fprintln(&b, "# TYPE realm_http_attestation_pending gauge")
	for _, node := range nodes {
		fmt.Fprintf(&b, "realm_http_attestation_pending{component=%q,node=%q} %d\n", m.component, node, m.pending[node])
	}
	fmt.Fprintln(&b, "# HELP realm_http_attestation_rejections_total Capacity and verified proof quota rejections.")
	fmt.Fprintln(&b, "# TYPE realm_http_attestation_rejections_total counter")
	lines = nil
	for k, count := range m.totals {
		if k.outcome == "failure" && (k.reason == "capacity" || k.reason == "rate_limit") {
			lines = append(lines, fmt.Sprintf("realm_http_attestation_rejections_total{component=%q,node=%q,stage=%q,reason=%q} %d\n", m.component, k.node, k.stage, k.reason, count))
		}
	}
	sort.Strings(lines)
	for _, line := range lines {
		b.WriteString(line)
	}
	if m.capacity > 0 {
		fmt.Fprintln(&b, "# HELP realm_http_attestation_capacity Maximum pending operations per server generation or responder.")
		fmt.Fprintln(&b, "# TYPE realm_http_attestation_capacity gauge")
		fmt.Fprintf(&b, "realm_http_attestation_capacity{component=%q} %d\n", m.component, m.capacity)
	}
	if m.component == "responder" {
		fmt.Fprintln(&b, "# HELP realm_http_responder_proofs_total Stored proof lifecycle operations, not enrollments.")
		fmt.Fprintln(&b, "# TYPE realm_http_responder_proofs_total counter")
		for _, node := range nodes {
			if node == "unknown" {
				continue
			}
			for _, action := range []string{"published", "deleted", "expired"} {
				fmt.Fprintf(&b, "realm_http_responder_proofs_total{component=\"responder\",node=%q,action=%q} %d\n", node, action, m.proofs[action])
			}
		}
	}
	m.mu.Unlock()
	w.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	_, _ = w.Write(b.Bytes())
}

package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	collectionInterval = 30 * time.Second
	collectionTimeout  = 20 * time.Second
	operationTimeout   = 5 * time.Second
	freshnessLimit     = 65 * time.Second
)

type sample struct {
	name   string
	labels []string
	value  float64
}

func metric(name string, value float64, labels ...string) sample { return sample{name, labels, value} }

type outcome struct {
	name       string
	samples    []sample
	err        error
	validUntil time.Time
}
type collectorState struct {
	samples                []sample
	success                bool
	successes, errors      uint64
	completed, lastSuccess time.Time
	validUntil             time.Time
}
type exporter struct {
	config            Config
	fetch             canaryFetcher
	command           commandRunner
	logger            *slog.Logger
	collectMu         sync.Mutex
	mu                sync.RWMutex
	states            map[string]collectorState
	holders           map[string]holderState
	canaryFingerprint string
	rotation          time.Time
}

func newExporter(c Config, logger *slog.Logger) *exporter {
	e := &exporter{config: c, fetch: fetchCanary, command: runCommand, logger: logger, states: map[string]collectorState{}, holders: map[string]holderState{}}
	for _, name := range []string{"bundle", "bootstrap", "canary"} {
		e.states[name] = collectorState{}
	}
	if c.ServerAdminSocket != "" {
		e.states["agents"] = collectorState{}
		e.states["aliases"] = collectorState{}
	}
	if len(c.Workloads) > 0 {
		e.states["workloads"] = collectorState{}
	}
	return e
}
func (e *exporter) collect(parent context.Context) {
	e.collectMu.Lock()
	defer e.collectMu.Unlock()
	ctx, cancel := context.WithTimeout(parent, collectionTimeout)
	defer cancel()
	var wg sync.WaitGroup
	task := func(fn func()) { wg.Add(1); go func() { defer wg.Done(); fn() }() }
	task(func() { e.collectBootstrap(ctx) })
	ready := make(chan struct{})
	var canary canaryResult
	task(func() {
		op, stop := context.WithTimeout(ctx, operationTimeout)
		defer stop()
		canary.metadata, canary.err = e.fetch(op, e.config)
		e.record(e.canaryOutcome(canary.metadata, canary.err))
		close(ready)
	})
	if len(e.config.Workloads) > 0 {
		task(func() { e.record(e.collectWorkloads(ctx, ready, &canary)) })
	}
	if e.config.ServerAdminSocket != "" {
		task(func() {
			op, stop := context.WithTimeout(ctx, operationTimeout)
			defer stop()
			e.record(e.collectAgents(op))
		})
		task(func() { e.record(e.collectAliases(ctx)) })
	}
	wg.Wait()
}
func (e *exporter) record(o outcome) {
	now := time.Now()
	e.mu.Lock()
	s := e.states[o.name]
	s.samples = o.samples
	s.completed = now
	s.success = o.err == nil
	s.validUntil = o.validUntil
	if s.success {
		s.successes++
		s.lastSuccess = now
	} else {
		s.errors++
	}
	e.states[o.name] = s
	e.mu.Unlock()
	if o.err != nil && e.logger != nil {
		e.logger.Warn("collection failed", "stage", o.name, "reason", safeReason(o.err))
	}
}
func (e *exporter) collectBootstrap(ctx context.Context) {
	certs, err := loadBundle(e.config.BundlePath)
	bundle := outcome{name: "bundle", err: err}
	if err == nil {
		now := time.Now()
		active := 0
		for _, cert := range certs {
			if certCurrent(cert, now) {
				active++
			}
			labels := []string{"node", e.config.Node, "certificate", fingerprint(cert)}
			bundle.samples = append(bundle.samples, metric("realm_bootstrap_bundle_certificate_not_after_seconds", float64(cert.NotAfter.Unix()), labels...), metric("realm_bootstrap_bundle_certificate_not_before_seconds", float64(cert.NotBefore.Unix()), labels...))
		}
		bundle.samples = append(bundle.samples, metric("realm_bootstrap_bundle_certificates", float64(len(certs)), "node", e.config.Node), metric("realm_bootstrap_bundle_active_valid_certificates", float64(active), "node", e.config.Node))
	}
	e.record(bundle)
	var validUntil time.Time
	if err == nil {
		op, stop := context.WithTimeout(ctx, operationTimeout)
		validUntil, err = probeBootstrap(op, e.config, certs)
		stop()
	}
	e.record(outcome{name: "bootstrap", err: err, validUntil: validUntil})
}
func (e *exporter) collectCanary(ctx context.Context) outcome {
	metadata, err := e.fetch(ctx, e.config)
	return e.canaryOutcome(metadata, err)
}
func (e *exporter) canaryOutcome(metadata canaryMetadata, err error) outcome {
	o := outcome{name: "canary"}
	if err != nil {
		o.err = err
		return o
	}
	if metadata.Cert == nil || !certCurrent(metadata.Cert, time.Now()) {
		o.err = fmt.Errorf("canary_metadata")
		return o
	}
	cert := metadata.Cert
	o.validUntil = cert.NotAfter
	fp := fingerprint(cert)
	// collectMu protects this process-local observation of a certificate change.
	if e.canaryFingerprint != "" && e.canaryFingerprint != fp {
		e.rotation = time.Now()
	}
	e.canaryFingerprint = fp
	labels := []string{"node", e.config.Node, "kind", "canary", "identity", e.config.canaryID()}
	o.samples = append(o.samples, metric("realm_identity_certificate_not_after_seconds", float64(cert.NotAfter.Unix()), labels...), metric("realm_identity_certificate_not_before_seconds", float64(cert.NotBefore.Unix()), labels...))
	if !e.rotation.IsZero() {
		o.samples = append(o.samples, metric("realm_identity_last_rotation_timestamp_seconds", float64(e.rotation.Unix()), labels...))
	}
	return o
}
func (e *exporter) collectAgents(ctx context.Context) outcome {
	o := outcome{name: "agents"}
	raw, err := e.command(ctx, e.config.SPIREServerBinary, "agent", "list", "-socketPath", e.config.ServerAdminSocket, "-output", "json")
	var agents []agentResult
	if err == nil {
		agents, err = parseAgents(raw, e.config, time.Now())
	}
	o.err = err
	found := map[string]agentResult{}
	for _, a := range agents {
		found[a.Node] = a
	}
	for _, node := range e.config.Nodes {
		a := found[node]
		o.samples = append(o.samples, metric("realm_spire_agent_metadata_valid", boolFloat(a.Valid), "node", node))
		if a.NotAfter > 0 {
			o.validUntil = earlier(o.validUntil, time.Unix(a.NotAfter, 0))
			o.samples = append(o.samples, metric("realm_identity_certificate_not_after_seconds", float64(a.NotAfter), "node", node, "kind", "agent", "identity", e.config.aliasID(node)))
		}
	}
	return o
}
func (e *exporter) collectAliases(ctx context.Context) outcome {
	o := outcome{name: "aliases"}
	for _, node := range e.config.Nodes {
		op, stop := context.WithTimeout(ctx, operationTimeout)
		raw, err := e.command(op, e.config.SPIREServerBinary, "entry", "show", "-spiffeID", e.config.aliasID(node), "-socketPath", e.config.ServerAdminSocket, "-output", "json")
		stop()
		validUntil, valid := aliasMetadata(raw, e.config, node, time.Now())
		valid = err == nil && valid
		if !valid {
			o.err = err
			if o.err == nil {
				o.err = errors.New("alias_metadata")
			}
		} else {
			o.validUntil = earlier(o.validUntil, validUntil)
		}
		o.samples = append(o.samples, metric("realm_spire_alias_matches_expected", boolFloat(valid), "node", node))
	}
	return o
}
func safeReason(err error) string {
	if errors.Is(err, context.DeadlineExceeded) {
		return "timeout"
	}
	if errors.Is(err, context.Canceled) {
		return "canceled"
	}
	if err == nil {
		return "none"
	}
	switch err.Error() {
	case "workload_unit_metadata", "workload_unit_not_active", "workload_observer_unavailable", "workload_address", "workload_identity", "workload_source", "workload_chain", "workload_request", "workload_http_status", "workload_body", "workload_expired", "workload_metadata":
		return err.Error()
	case "bundle_read", "bundle_format", "bundle_certificate", "bundle_limit", "bundle_empty", "bootstrap_domain", "bootstrap_identity", "bootstrap_handshake", "bootstrap_chain", "canary_connect", "canary_fetch", "canary_metadata", "canary_missing", "admin_command", "admin_output_limit", "agents_json", "agents_metadata", "alias_metadata":
		return err.Error()
	default:
		return "collection_failed"
	}
}

func boolFloat(b bool) float64 {
	if b {
		return 1
	}
	return 0
}
func earlier(a, b time.Time) time.Time {
	if b.IsZero() {
		return a
	}
	if a.IsZero() || b.Before(a) {
		return b
	}
	return a
}
func fresh(s collectorState, now time.Time) bool {
	return !s.completed.IsZero() && now.Sub(s.completed) <= freshnessLimit
}
func successful(s collectorState, now time.Time) bool {
	return s.success && fresh(s, now) && (s.validUntil.IsZero() || now.Before(s.validUntil))
}
func currentSamples(s collectorState, now time.Time) []sample {
	if fresh(s, now) {
		result := append([]sample(nil), s.samples...)
		expiredNodes := map[string]bool{}
		before, after := map[string]float64{}, map[string]float64{}
		for _, m := range result {
			if m.name == "realm_identity_certificate_not_after_seconds" && m.value <= float64(now.Unix()) {
				expiredNodes[labelValue(m, "node")] = true
			}
			if m.name == "realm_bootstrap_bundle_certificate_not_before_seconds" {
				before[labelValue(m, "certificate")] = m.value
			}
			if m.name == "realm_bootstrap_bundle_certificate_not_after_seconds" {
				after[labelValue(m, "certificate")] = m.value
			}
		}
		for i, m := range result {
			if m.name == "realm_spire_agent_metadata_valid" && expiredNodes[labelValue(m, "node")] {
				result[i].value = 0
			}
			if m.name == "realm_spire_alias_matches_expected" && !s.validUntil.IsZero() && !now.Before(s.validUntil) {
				result[i].value = 0
			}
			if m.name == "realm_bootstrap_bundle_active_valid_certificates" {
				result[i].value = 0
				for fp, expiry := range after {
					if before[fp] <= float64(now.Unix()) && expiry > float64(now.Unix()) {
						result[i].value++
					}
				}
			}
		}
		return result
	}
	// Keep explicit failure indicators when all other samples expire.
	var result []sample
	for _, m := range s.samples {
		if m.name == "realm_spire_agent_metadata_valid" || m.name == "realm_spire_alias_matches_expected" {
			m.value = 0
			result = append(result, m)
		}
	}
	return result
}
func labelValue(m sample, key string) string {
	for i := 0; i < len(m.labels); i += 2 {
		if m.labels[i] == key {
			return m.labels[i+1]
		}
	}
	return ""
}
func (e *exporter) healthy(now time.Time) bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	for _, s := range e.states {
		if !successful(s, now) {
			return false
		}
	}
	for _, target := range e.config.Workloads {
		s := e.holders[target.Unit]
		if s.dormant && holderFresh(s, now) {
			continue
		}
		if !holderSuccessful(s, now) {
			return false
		}
	}
	return true
}
func (e *exporter) metrics(w io.Writer, now time.Time) {
	e.mu.RLock()
	states := make(map[string]collectorState, len(e.states))
	for name, state := range e.states {
		states[name] = state
	}
	holders := make(map[string]holderState, len(e.holders))
	for unit, state := range e.holders {
		holders[unit] = state
	}
	e.mu.RUnlock()
	var samples []sample
	samples = append(samples, holderSamples(e.config, holders, now)...)
	names := make([]string, 0, len(states))
	for name := range states {
		names = append(names, name)
	}
	sort.Strings(names)
	for _, name := range names {
		s := states[name]
		labels := []string{"node", e.config.Node, "collector", name}
		samples = append(samples, metric("realm_identity_collector_success", boolFloat(successful(s, now)), labels...), metric("realm_identity_collector_successes_total", float64(s.successes), labels...), metric("realm_identity_collector_errors_total", float64(s.errors), labels...), metric("realm_identity_collector_last_success_timestamp_seconds", unixOrZero(s.lastSuccess), labels...), metric("realm_identity_collector_last_collection_timestamp_seconds", unixOrZero(s.completed), labels...))
		samples = append(samples, currentSamples(s, now)...)
	}
	bootstrap := states["bootstrap"]
	samples = append(samples, metric("realm_bootstrap_bundle_server_trust_valid", boolFloat(successful(bootstrap, now)), "node", e.config.Node))
	for _, name := range metricNames() {
		fmt.Fprintf(w, "# HELP %s %s\n# TYPE %s %s\n", name, metricHelp[name], name, metricType(name))
		for _, m := range samples {
			if m.name == name {
				writeSample(w, m)
			}
		}
	}
}
func unixOrZero(t time.Time) float64 {
	if t.IsZero() {
		return 0
	}
	return float64(t.Unix())
}
func writeSample(w io.Writer, m sample) {
	var b strings.Builder
	b.WriteString(m.name)
	if len(m.labels) > 0 {
		b.WriteByte('{')
		for i := 0; i < len(m.labels); i += 2 {
			if i > 0 {
				b.WriteByte(',')
			}
			b.WriteString(m.labels[i])
			b.WriteByte('=')
			b.WriteString(strconv.Quote(m.labels[i+1]))
		}
		b.WriteByte('}')
	}
	fmt.Fprintf(w, "%s %s\n", b.String(), strconv.FormatFloat(m.value, 'g', -1, 64))
}

var metricHelp = map[string]string{
	"realm_workload_svid_observation_success":                    "One if this unit has a current successful observation. Ghostunnel describes its status watch only.",
	"realm_workload_svid_dormant":                                "One if the latest current systemctl result reports this unit inactive. No certificate observation occurs.",
	"realm_workload_svid_last_attempt_timestamp_seconds":         "Unix time of the last completed observation attempt or dormant state read.",
	"realm_workload_svid_last_observed_timestamp_seconds":        "Unix time of the last successful public certificate observation, or zero.",
	"realm_workload_svid_observation_successes_total":            "Successful public certificate observations since process start.",
	"realm_workload_svid_observation_errors_total":               "Failed observation attempts since process start. Dormant units do not count as errors.",
	"realm_workload_svid_not_before_seconds":                     "Observed public leaf start of validity as Unix time. Source labels identify the interface.",
	"realm_workload_svid_not_after_seconds":                      "Observed public leaf expiry as Unix time. Ghostunnel status watches do not prove business certificate state.",
	"realm_workload_svid_last_rotation_timestamp_seconds":        "Unix time when this process observed a change in the TLS peer leaf fingerprint.",
	"realm_identity_collector_success":                           "One if the latest collection succeeded and is fresh.",
	"realm_identity_collector_successes_total":                   "Successful collections since process start.",
	"realm_identity_collector_errors_total":                      "Failed collections since process start.",
	"realm_identity_collector_last_success_timestamp_seconds":    "Unix time of the last successful collection, or zero before success.",
	"realm_identity_collector_last_collection_timestamp_seconds": "Unix time of the last completed collection, or zero before collection.",
	"realm_bootstrap_bundle_server_trust_valid":                  "One if a fresh TLS 1.3 server handshake passed with the exact pinned bundle and server SPIFFE ID.",
	"realm_bootstrap_bundle_certificates":                        "Number of distinct CA certificates in the configured bundle.",
	"realm_bootstrap_bundle_active_valid_certificates":           "Number of bundle CA certificates within their validity period. This count is not proof of server trust.",
	"realm_bootstrap_bundle_certificate_not_after_seconds":       "Public bundle CA expiration as Unix time.",
	"realm_bootstrap_bundle_certificate_not_before_seconds":      "Public bundle CA start of validity as Unix time.",
	"realm_identity_certificate_not_after_seconds":               "Certificate expiration as Unix time for the own canary or registered agent metadata.",
	"realm_identity_certificate_not_before_seconds":              "Own canary certificate start of validity as Unix time.",
	"realm_identity_last_rotation_timestamp_seconds":             "Unix time when this process observed its canary certificate change. Absent before a change.",
	"realm_spire_agent_metadata_valid":                           "One if the expected http_fqdn agent has current metadata, is not banned, and can reattest.",
	"realm_spire_alias_matches_expected":                         "One if exactly one stable alias entry has the expected parent and SPIFFE ID selector.",
}

func metricNames() []string {
	names := make([]string, 0, len(metricHelp))
	for name := range metricHelp {
		names = append(names, name)
	}
	sort.Strings(names)
	return names
}
func metricType(name string) string {
	if strings.HasSuffix(name, "_total") {
		return "counter"
	}
	return "gauge"
}
func (e *exporter) handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" {
			w.WriteHeader(http.StatusMethodNotAllowed)
			return
		}
		w.Header().Set("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
		e.metrics(w, time.Now())
	})
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		if !e.healthy(time.Now()) {
			w.WriteHeader(http.StatusServiceUnavailable)
			fmt.Fprintln(w, "collection unavailable")
			return
		}
		fmt.Fprintln(w, "ok")
	})
	return mux
}
func (e *exporter) loop(ctx context.Context) {
	e.collect(ctx)
	ticker := time.NewTicker(collectionInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			e.collect(ctx)
		}
	}
}

package main

import (
	"errors"
	"time"
)

type holderState struct {
	attempted, observed, rotated time.Time
	before, after, validUntil    time.Time
	fingerprint                  string
	success, dormant             bool
	successes, errors            uint64
}

func (e *exporter) recordHolder(target WorkloadTarget, o holderObservation) error {
	if o.err == nil && !o.dormant && (o.fingerprint == "" || o.before.IsZero() || !o.after.After(o.before) || o.validUntil.IsZero() || !time.Now().Before(o.validUntil)) {
		o.err = errors.New("workload_metadata")
	}
	now := time.Now()
	e.mu.Lock()
	s := e.holders[target.Unit]
	s.attempted = now
	s.dormant = o.dormant && o.err == nil
	s.success = o.err == nil && !o.dormant
	s.before = time.Time{}
	s.after = time.Time{}
	s.validUntil = time.Time{}
	if s.success {
		if s.fingerprint != "" && s.fingerprint != o.fingerprint {
			s.rotated = now
		}
		s.fingerprint = o.fingerprint
		s.before = o.before
		s.after = o.after
		s.validUntil = o.validUntil
		s.observed = now
		s.successes++
	} else if o.err != nil {
		s.errors++
	}
	e.holders[target.Unit] = s
	e.mu.Unlock()
	if o.err != nil && e.logger != nil {
		e.logger.Warn("workload observation failed", "stage", "workloads", "reason", safeReason(o.err))
	}
	return o.err
}
func holderFresh(s holderState, now time.Time) bool {
	return !s.attempted.IsZero() && now.Sub(s.attempted) <= freshnessLimit
}
func holderSuccessful(s holderState, now time.Time) bool {
	return s.success && holderFresh(s, now) && !s.validUntil.IsZero() && now.Before(s.validUntil)
}
func holderSamples(c Config, states map[string]holderState, now time.Time) []sample {
	var samples []sample
	for _, target := range c.Workloads {
		s := states[target.Unit]
		labels := []string{"node", c.Node, "unit", target.Unit, "identity", target.Identity, "source", target.Source}
		samples = append(samples,
			metric("realm_workload_svid_observation_success", boolFloat(holderSuccessful(s, now)), labels...),
			metric("realm_workload_svid_dormant", boolFloat(s.dormant && holderFresh(s, now)), labels...),
			metric("realm_workload_svid_last_attempt_timestamp_seconds", unixOrZero(s.attempted), labels...),
			metric("realm_workload_svid_last_observed_timestamp_seconds", unixOrZero(s.observed), labels...),
			metric("realm_workload_svid_observation_successes_total", float64(s.successes), labels...),
			metric("realm_workload_svid_observation_errors_total", float64(s.errors), labels...),
		)
		if holderSuccessful(s, now) {
			samples = append(samples, metric("realm_workload_svid_not_before_seconds", float64(s.before.Unix()), labels...), metric("realm_workload_svid_not_after_seconds", float64(s.after.Unix()), labels...))
			if !s.rotated.IsZero() {
				samples = append(samples, metric("realm_workload_svid_last_rotation_timestamp_seconds", float64(s.rotated.Unix()), labels...))
			}
		}
	}
	return samples
}

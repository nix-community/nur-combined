package main

import (
	"bytes"
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
)

func TestWorkloadObserverFetchParallelStateReadAndIsolation(t *testing.T) {
	// Each exporter has its own observer identity and trust bundle. Neither can
	// authenticate to the other's holders, even while their cycles overlap.
	started := make(chan struct{}, 4)
	release := make(chan struct{})
	defer close(release)
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	type running struct {
		exporter *exporter
		fetches  *atomic.Int32
		done     chan struct{}
	}
	var cycles []running
	for _, node := range []string{"eihort", "nodens"} {
		c := holderConfig()
		c.Node = node
		c.BundlePath = t.TempDir() + "/missing.pem"
		now := time.Now()
		ca := newCA(t, now.Add(-time.Hour), now.Add(2*time.Hour))
		observer := observerCredentials(t, ca, c)
		for _, source := range []string{sourceCaddy, sourceGhostunnel} {
			target := c.Workloads[0]
			target.Unit = source + ".service"
			target.Source = source
			cert, _ := ca.leaf(t, []string{target.Identity}, now.Add(-time.Minute), now.Add(time.Hour))
			target.Address = serveHolderTLS(t, cert, observer.Bundle, tlsconfig.AuthorizeID(spiffeid.RequireFromString(c.canaryID())), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if source == sourceCaddy {
					w.WriteHeader(http.StatusNoContent)
				} else {
					w.WriteHeader(http.StatusOK)
				}
			}))
			c.Workloads = append(c.Workloads, target)
		}
		c.Workloads = c.Workloads[1:]
		e := newExporter(c, nil)
		fetches := new(atomic.Int32)
		e.fetch = func(ctx context.Context, _ Config) (canaryMetadata, error) {
			fetches.Add(1)
			started <- struct{}{}
			select {
			case <-release:
				return observer, nil
			case <-ctx.Done():
				return canaryMetadata{}, ctx.Err()
			}
		}
		e.command = func(ctx context.Context, _ string, _ ...string) ([]byte, error) {
			started <- struct{}{}
			select {
			case <-release:
				return activityJSON(c.Workloads), nil
			case <-ctx.Done():
				return nil, ctx.Err()
			}
		}
		done := make(chan struct{})
		go func() { defer close(done); e.collect(ctx) }()
		cycles = append(cycles, running{e, fetches, done})
	}
	// Both state reads must start before either observer fetch completes.
	for i := 0; i < 4; i++ {
		select {
		case <-started:
		case <-ctx.Done():
			t.Fatal("observer fetch and state read did not run independently")
		}
	}
	for _, cycle := range cycles {
		response := httptest.NewRecorder()
		cycle.exporter.handler().ServeHTTP(response, httptest.NewRequest("GET", "/metrics", nil))
		if response.Code != http.StatusOK {
			t.Fatal("pending observer blocked metrics")
		}
	}
	// Send one token to each blocked operation; closing is deferred for cleanup.
	for i := 0; i < 4; i++ {
		select {
		case release <- struct{}{}:
		case <-ctx.Done():
			t.Fatal("collection did not accept release")
		}
	}
	for _, cycle := range cycles {
		select {
		case <-cycle.done:
		case <-ctx.Done():
			t.Fatal("collection did not complete")
		}
		if cycle.fetches.Load() != 1 || !cycle.exporter.states["canary"].success || !cycle.exporter.states["workloads"].success {
			t.Fatal("cycle did not use exactly one successful observer fetch")
		}
		for _, target := range cycle.exporter.config.Workloads {
			if !cycle.exporter.holders[target.Unit].success {
				t.Fatal("concurrent cycles mixed observer credentials")
			}
		}
	}
}

func TestWorkloadFailureAndDormancyRevokeCertificateEvidence(t *testing.T) {
	for _, source := range []string{sourceCaddy, sourceGhostunnel} {
		for _, state := range []string{"inactive", "failed", "command_failure"} {
			t.Run(source+"/"+state, func(t *testing.T) {
				c := holderConfig()
				c.Workloads[0].Source = source
				e := newExporter(c, nil)
				target := c.Workloads[0]
				now := time.Now()
				observation := holderObservation{before: now.Add(-time.Hour), after: now.Add(time.Hour), validUntil: now.Add(time.Hour), fingerprint: "first"}
				e.recordHolder(target, observation)
				observation.fingerprint = "second"
				e.recordHolder(target, observation)
				previous := e.holders[target.Unit]
				if previous.rotated.IsZero() {
					t.Fatal("fixture has no rotation evidence")
				}
				e.command = func(context.Context, string, ...string) ([]byte, error) {
					if state == "command_failure" {
						return nil, errors.New("failed")
					}
					return activityJSON(c.Workloads, state), nil
				}
				// A pending observer cannot delay revocation for nonactive units.
				ctx, cancel := context.WithTimeout(context.Background(), time.Second)
				defer cancel()
				e.collectWorkloads(ctx, make(chan struct{}), &canaryResult{})
				holder := e.holders[target.Unit]
				if holder.success || holder.dormant != (state == "inactive") || !holder.observed.Equal(previous.observed) || holder.fingerprint != previous.fingerprint || !holder.rotated.Equal(previous.rotated) {
					t.Fatal("revocation lost history or retained success")
				}
				if !holder.before.IsZero() || !holder.after.IsZero() || !holder.validUntil.IsZero() || holder.errors != uint64(boolFloat(state != "inactive")) {
					t.Fatal("revocation retained certificate validity or miscounted errors")
				}
				var b bytes.Buffer
				e.metrics(&b, time.Now())
				for _, name := range []string{"realm_workload_svid_not_before_seconds{", "realm_workload_svid_not_after_seconds{", "realm_workload_svid_last_rotation_timestamp_seconds{"} {
					if strings.Contains(b.String(), name) {
						t.Fatal("revoked certificate evidence remained in metrics")
					}
				}
				// A successful observation restores samples without inventing rotation.
				e.recordHolder(target, observation)
				if !e.holders[target.Unit].success || e.holders[target.Unit].dormant || !e.holders[target.Unit].rotated.Equal(previous.rotated) {
					t.Fatal("fresh observation did not restore holder evidence")
				}
			})
		}
	}
}

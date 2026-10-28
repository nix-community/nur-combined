package nodeattest

import (
	"context"
	"encoding/json"
	"io"
	"log"
	"net"
	"net/http"
	"path/filepath"
	"testing"
	"time"

	"github.com/spiffe/spire-plugin-sdk/plugintest"
	agentv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/agent/nodeattestor/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type agentResultPlugin struct {
	*AgentPlugin
	result chan error
}

func (p *agentResultPlugin) AidAttestation(stream agentv1.NodeAttestor_AidAttestationServer) error {
	err := p.AgentPlugin.AidAttestation(stream)
	p.result <- err
	return err
}

type agentMetricEvents chan []byte

func (events agentMetricEvents) Write(data []byte) (int, error) {
	events <- append([]byte(nil), data...)
	return len(data), nil
}

type cancelBeforeReady struct {
	*fakeAgentAttempt
	cancel context.CancelFunc
}

func (a *cancelBeforeReady) Respond(context.Context, []byte) ([]byte, error) {
	a.cancel()
	return []byte("synthetic-proof"), nil
}

func TestAgentCancellationBeforeResponseSendRemainsFailure(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	attempt := &cancelBeforeReady{fakeAgentAttempt: new(fakeAgentAttempt), cancel: cancel}
	// Simulate a transport that reports no Send error despite prior cancellation.
	stream := &fakeAgentStream{ctx: ctx, attempt: attempt.fakeAgentAttempt}
	metrics := quietMetrics("agent", fixtureFQDN)
	err := aidAttestation(stream, AgentConfig{FQDN: fixtureFQDN}, func(AgentConfig) (agentPluginAttempt, error) { return attempt, nil }, metrics)
	if status.Code(err) != codes.Canceled || stream.sends != 2 || !attempt.closed {
		t.Fatal("cancellation changed the protocol return or cleanup")
	}
	if len(metrics.totals) != 1 || metrics.totals[metricLabels{fixtureFQDN, "failure", "response", "canceled"}] != 1 {
		t.Fatal("cancellation before submission counted as success")
	}
	if metrics.lastSuccess[fixtureFQDN] != 0 || metrics.durations[durationLabels{fixtureFQDN, "failure"}].count != 1 {
		t.Fatal("cancellation before submission updated success metrics")
	}
}

func TestAgentRPCCancellationBeforeAndAfterProofSubmission(t *testing.T) {
	for _, submitted := range []bool{false, true} {
		name := "before challenge"
		if submitted {
			name = "after ready response"
		}
		t.Run(name, func(t *testing.T) {
			r, err := newResponder(ResponderConfig{FQDN: fixtureFQDN, Port: DefaultPort, ControlSocket: filepath.Join(t.TempDir(), "control.sock")})
			if err != nil {
				t.Fatal(err)
			}
			r.metrics.events = nil
			listener, err := net.Listen("unix", r.config.ControlSocket)
			if err != nil {
				t.Fatal(err)
			}
			control := &http.Server{Handler: http.HandlerFunc(r.control), ErrorLog: log.New(io.Discard, "", 0), ConnContext: func(ctx context.Context, _ net.Conn) context.Context {
				// The fixture supplies authority. Production uses kernel peer credentials.
				return context.WithValue(ctx, controlPeerKey{}, true)
			}}
			go func() { _ = control.Serve(listener) }()
			defer control.Close()

			metrics := quietMetrics("agent", fixtureFQDN)
			events := make(agentMetricEvents, 4)
			metrics.events = events
			plugin := &agentResultPlugin{AgentPlugin: &AgentPlugin{config: &AgentConfig{FQDN: fixtureFQDN, TrustDomain: "nyaw.xyz", ControlSocket: r.config.ControlSocket}, metrics: metrics}, result: make(chan error, 1)}
			client := new(agentv1.NodeAttestorPluginClient)
			plugintest.ServeInBackground(t, plugintest.Config{PluginServer: agentv1.NodeAttestorPluginServer(plugin), PluginClient: client})
			ctx, stop := context.WithTimeout(context.Background(), 5*time.Second)
			defer stop()
			streamCtx, cancel := context.WithCancel(ctx)
			defer cancel()
			stream, err := client.AidAttestation(streamCtx)
			if err != nil {
				t.Fatal(err)
			}
			payload, err := stream.Recv()
			if err != nil || len(payload.GetPayload()) == 0 {
				t.Fatal("agent did not send payload")
			}
			var eventData []byte
			if submitted {
				server, err := NewServer(fixtureConfig())
				if err != nil {
					t.Fatal(err)
				}
				attempt, err := server.Begin(ctx, payload.GetPayload())
				if err != nil {
					t.Fatal(err)
				}
				defer attempt.Close()
				if stream.Send(&agentv1.Challenge{Challenge: attempt.Challenge()}) != nil {
					t.Fatal("cannot send fixture challenge")
				}
				response, err := stream.Recv()
				if err != nil || len(response.GetChallengeResponse()) == 0 {
					t.Fatal("agent did not submit ready response")
				}
				// Confirm Send returned successfully before Core cancels its RPC.
				select {
				case eventData = <-events:
				case <-ctx.Done():
					t.Fatal("submission did not emit a local success event")
				}
				metrics.mu.Lock()
				pending := metrics.pending[fixtureFQDN]
				metrics.mu.Unlock()
				if pending != 1 {
					t.Fatal("proof stream ended before Core closed it")
				}
				r.mu.Lock()
				published := len(r.proofs)
				r.mu.Unlock()
				if published != 1 {
					t.Fatal("proof did not remain published for Core")
				}
				// No Verify call or issuance occurs in this fixture.
			}
			cancel()
			select {
			case err := <-plugin.result:
				if status.Code(err) != codes.Canceled {
					t.Fatal("cancellation changed the RPC error return")
				}
			case <-ctx.Done():
				t.Fatal("canceled agent RPC did not finish")
			}
			if !submitted {
				select {
				case eventData = <-events:
				case <-ctx.Done():
					t.Fatal("cancellation did not emit a failure event")
				}
			}
			metrics.mu.Lock()
			defer metrics.mu.Unlock()
			outcome, stage, reason := "failure", "challenge", "canceled"
			if submitted {
				outcome, stage, reason = "success", "response", "proof_submitted"
			}
			if len(metrics.totals) != 1 || metrics.totals[metricLabels{fixtureFQDN, outcome, stage, reason}] != 1 {
				t.Fatal("incorrect local submission outcome")
			}
			if len(metrics.durations) != 1 || metrics.durations[durationLabels{fixtureFQDN, outcome}].count != 1 {
				t.Fatal("histogram counted stream cancellation instead of submission")
			}
			if (metrics.lastSuccess[fixtureFQDN] > 0) != submitted || metrics.pending[fixtureFQDN] != 0 {
				t.Fatal("incorrect submission gauges")
			}
			if len(events) != 0 {
				t.Fatal("stream cancellation emitted a second outcome")
			}
			var event map[string]any
			if json.Unmarshal(eventData, &event) != nil || event["outcome"] != outcome || event["reason"] != reason || event["stage"] != stage {
				t.Fatal("incorrect structured event outcome")
			}
			r.mu.Lock()
			defer r.mu.Unlock()
			if len(r.proofs) != 0 {
				t.Fatal("stream cancellation did not clean its published proof")
			}
		})
	}
}

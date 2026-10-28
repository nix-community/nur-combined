package nodeattest

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/spiffe/spire-plugin-sdk/pluginsdk"
	"github.com/spiffe/spire-plugin-sdk/plugintest"
	agentv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/agent/nodeattestor/v1"
	serverv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/server/nodeattestor/v1"
	configv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/service/common/config/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

func serveServerAdapter(t *testing.T, plugin *ServerPlugin) (*serverv1.NodeAttestorPluginClient, *configv1.ConfigServiceClient) {
	t.Helper()
	client := new(serverv1.NodeAttestorPluginClient)
	configClient := new(configv1.ConfigServiceClient)
	plugintest.ServeInBackground(t, plugintest.Config{
		PluginServer:   serverv1.NodeAttestorPluginServer(plugin),
		PluginClient:   client,
		ServiceServers: []pluginsdk.ServiceServer{configv1.ConfigServiceServer(plugin)},
		ServiceClients: []pluginsdk.ServiceClient{configClient},
	})
	return client, configClient
}

func configRequest(t *testing.T, data string) *configv1.ConfigureRequest {
	t.Helper()
	path := filepath.Join(t.TempDir(), "config.json")
	if err := os.WriteFile(path, []byte(data), 0600); err != nil {
		t.Fatal(err)
	}
	return &configv1.ConfigureRequest{
		CoreConfiguration: &configv1.CoreConfiguration{TrustDomain: "example.org"},
		HclConfiguration:  fmt.Sprintf("config_file = %q", path),
	}
}

func TestAdaptersRequireConfiguration(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	server, _ := serveServerAdapter(t, new(ServerPlugin))
	serverStream, err := server.Attest(ctx)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := serverStream.Recv(); status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("server status: %v", err)
	}

	plugin := new(AgentPlugin)
	agent := new(agentv1.NodeAttestorPluginClient)
	plugintest.ServeInBackground(t, plugintest.Config{
		PluginServer:   agentv1.NodeAttestorPluginServer(plugin),
		PluginClient:   agent,
		ServiceServers: []pluginsdk.ServiceServer{configv1.ConfigServiceServer(plugin)},
	})
	agentStream, err := agent.AidAttestation(ctx)
	if err != nil {
		t.Fatal(err)
	}
	if _, err := agentStream.Recv(); status.Code(err) != codes.FailedPrecondition {
		t.Fatalf("agent status: %v", err)
	}
}

func TestConfigureTrustDomainAndRetainAgentSnapshot(t *testing.T) {
	plugin := new(AgentPlugin)
	client := new(agentv1.NodeAttestorPluginClient)
	configClient := new(configv1.ConfigServiceClient)
	plugintest.ServeInBackground(t, plugintest.Config{
		PluginServer:   agentv1.NodeAttestorPluginServer(plugin),
		PluginClient:   client,
		ServiceServers: []pluginsdk.ServiceServer{configv1.ConfigServiceServer(plugin)},
		ServiceClients: []pluginsdk.ServiceClient{configClient},
	})
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	req := configRequest(t, `{"fqdn":"node.example.org","trust_domain":"example.org","control_socket":"/run/synthetic/control.sock"}`)
	if _, err := configClient.Configure(ctx, req); err != nil {
		t.Fatal(err)
	}
	plugin.mu.RLock()
	original := plugin.config
	plugin.mu.RUnlock()

	for _, data := range []string{
		`{"fqdn":"other.example.org","trust_domain":"other.example.org","control_socket":"/run/synthetic/other.sock"}`,
		`{"fqdn":"node.example.org","trust_domain":"example.org","control_socket":"/run/synthetic/control.sock"} {}`,
	} {
		if _, err := configClient.Configure(ctx, configRequest(t, data)); status.Code(err) != codes.InvalidArgument {
			t.Fatalf("Configure status: %v", err)
		}
	}
	plugin.mu.RLock()
	retained := plugin.config
	plugin.mu.RUnlock()
	if retained != original || retained.FQDN != "node.example.org" {
		t.Fatal("failed Configure replaced the active configuration")
	}

	_, serverConfig := serveServerAdapter(t, new(ServerPlugin))
	mismatch := configRequest(t, `{"trust_domain":"other.example.org","trust_http_transport":true}`)
	if _, err := serverConfig.Configure(ctx, mismatch); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("server trust domain status: %v", err)
	}
	insecure := configRequest(t, `{"trust_domain":"example.org","trust_http_transport":false,"nodes":{"synthetic":{"fqdn":"node.example.org","addresses":["2606:4700:4700::1111"]}}}`)
	if _, err := serverConfig.Configure(ctx, insecure); status.Code(err) != codes.InvalidArgument {
		t.Fatalf("server HTTP transport status: %v", err)
	}
}

type fakeServerAttempt struct {
	ctx    context.Context
	verify func(context.Context, []byte) (*Result, error)
	close  func()
}

func (a *fakeServerAttempt) Context() context.Context {
	if a.ctx != nil {
		return a.ctx
	}
	return context.Background()
}
func (*fakeServerAttempt) Challenge() []byte { return []byte("synthetic-challenge") }
func (a *fakeServerAttempt) Verify(ctx context.Context, response []byte) (*Result, error) {
	return a.verify(ctx, response)
}
func (a *fakeServerAttempt) Close() { a.close() }

func TestServerConcurrentStreamsAndCancellation(t *testing.T) {
	const count = 12
	var starts, closes atomic.Int32
	closed := make(chan struct{}, count+1)
	plugin := &ServerPlugin{begin: func(_ context.Context, payload []byte) (serverPluginAttempt, error) {
		starts.Add(1)
		id := string(payload)
		return &fakeServerAttempt{
			verify: func(_ context.Context, response []byte) (*Result, error) {
				if string(response) != "response-"+id {
					return nil, errors.New("response belongs to another stream")
				}
				return &Result{AgentID: "spiffe://example.org/spire/agent/http_fqdn/" + id, SelectorValues: []string{"fqdn:" + id + ".example.org"}}, nil
			},
			close: func() { closes.Add(1); closed <- struct{}{} },
		}, nil
	}}
	client, _ := serveServerAdapter(t, plugin)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	var wg sync.WaitGroup
	for i := 0; i < count; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			id := fmt.Sprintf("node-%d", i)
			stream, err := client.Attest(ctx)
			if err != nil {
				t.Error(err)
				return
			}
			if err := stream.Send(&serverv1.AttestRequest{Request: &serverv1.AttestRequest_Payload{Payload: []byte(id)}}); err != nil {
				t.Error(err)
				return
			}
			challenge, err := stream.Recv()
			if err != nil {
				t.Error(err)
				return
			}
			if string(challenge.GetChallenge()) != "synthetic-challenge" || challenge.GetAgentAttributes() != nil {
				t.Error("invalid challenge response")
				return
			}
			if err := stream.Send(&serverv1.AttestRequest{Request: &serverv1.AttestRequest_ChallengeResponse{ChallengeResponse: []byte("response-" + id)}}); err != nil {
				t.Error(err)
				return
			}
			response, err := stream.Recv()
			if err != nil {
				t.Error(err)
				return
			}
			attrs := response.GetAgentAttributes()
			if attrs.GetSpiffeId() != "spiffe://example.org/spire/agent/http_fqdn/"+id || !attrs.GetCanReattest() {
				t.Errorf("invalid agent attributes: %v", attrs)
				return
			}
			if len(attrs.SelectorValues) != 1 || attrs.SelectorValues[0] != "fqdn:"+id+".example.org" {
				t.Error("adapter changed selector values")
			}
			if _, err := stream.Recv(); !errors.Is(err, io.EOF) {
				t.Errorf("stream completion: %v", err)
			}
		}(i)
	}
	wg.Wait()
	for i := 0; i < count; i++ {
		select {
		case <-closed:
		case <-ctx.Done():
			t.Fatal("attempt did not close")
		}
	}

	cancelCtx, stop := context.WithCancel(ctx)
	defer stop()
	stream, err := client.Attest(cancelCtx)
	if err != nil {
		t.Fatal(err)
	}
	if err := stream.Send(&serverv1.AttestRequest{Request: &serverv1.AttestRequest_Payload{Payload: []byte("canceled")}}); err != nil {
		t.Fatal(err)
	}
	if _, err := stream.Recv(); err != nil {
		t.Fatal(err)
	}
	stop()
	select {
	case <-closed:
	case <-ctx.Done():
		t.Fatal("canceled attempt did not close")
	}
	if starts.Load() != count+1 || closes.Load() != count+1 {
		t.Fatalf("starts=%d closes=%d", starts.Load(), closes.Load())
	}
}

func TestServerAttemptDeadlineReleasesIdleStream(t *testing.T) {
	closed := make(chan struct{})
	var verified atomic.Bool
	plugin := &ServerPlugin{begin: func(ctx context.Context, _ []byte) (serverPluginAttempt, error) {
		attemptCtx, cancel := context.WithTimeout(ctx, 100*time.Millisecond)
		return &fakeServerAttempt{
			ctx: attemptCtx,
			verify: func(context.Context, []byte) (*Result, error) {
				verified.Store(true)
				return nil, errors.New("unexpected verification")
			},
			close: func() { cancel(); close(closed) },
		}, nil
	}}
	client, _ := serveServerAdapter(t, plugin)
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	stream, err := client.Attest(ctx)
	if err != nil {
		t.Fatal(err)
	}
	if err := stream.Send(&serverv1.AttestRequest{Request: &serverv1.AttestRequest_Payload{Payload: []byte("idle-node")}}); err != nil {
		t.Fatal(err)
	}
	if _, err := stream.Recv(); err != nil {
		t.Fatal(err)
	}
	// Send no proof. The attempt deadline must end the pending Recv.
	if _, err := stream.Recv(); status.Code(err) != codes.DeadlineExceeded {
		t.Fatalf("idle stream status: %v", err)
	}
	select {
	case <-closed:
	case <-ctx.Done():
		t.Fatal("expired attempt did not close")
	}
	if verified.Load() {
		t.Fatal("idle stream reached verification")
	}
}

type fakeServerStream struct {
	grpc.ServerStream
	requests  []*serverv1.AttestRequest
	recvErr   error
	sendErrAt int
	sends     int
}

func (*fakeServerStream) Context() context.Context { return context.Background() }
func (s *fakeServerStream) Recv() (*serverv1.AttestRequest, error) {
	if len(s.requests) == 0 {
		return nil, s.recvErr
	}
	req := s.requests[0]
	s.requests = s.requests[1:]
	return req, nil
}
func (s *fakeServerStream) Send(*serverv1.AttestResponse) error {
	s.sends++
	if s.sends == s.sendErrAt {
		return io.ErrClosedPipe
	}
	return nil
}

func TestServerClosesAttemptOnStreamAndProofErrors(t *testing.T) {
	payload := &serverv1.AttestRequest{Request: &serverv1.AttestRequest_Payload{Payload: []byte("synthetic-payload")}}
	proof := &serverv1.AttestRequest{Request: &serverv1.AttestRequest_ChallengeResponse{ChallengeResponse: []byte("synthetic-proof")}}
	for _, tc := range []struct {
		name       string
		sendErrAt  int
		recvErr    error
		wrongProof bool
		verifyErr  bool
	}{
		{name: "send challenge", sendErrAt: 1},
		{name: "receive proof", recvErr: io.ErrUnexpectedEOF},
		{name: "proof EOF", recvErr: io.EOF},
		{name: "wrong message", wrongProof: true},
		{name: "failed proof", verifyErr: true},
		{name: "send attributes", sendErrAt: 2},
	} {
		t.Run(tc.name, func(t *testing.T) {
			closes := 0
			plugin := &ServerPlugin{begin: func(context.Context, []byte) (serverPluginAttempt, error) {
				return &fakeServerAttempt{close: func() { closes++ }, verify: func(context.Context, []byte) (*Result, error) {
					if tc.verifyErr {
						return nil, errors.New("synthetic-secret-nonce")
					}
					return &Result{AgentID: "spiffe://example.org/spire/agent/http_fqdn/node"}, nil
				}}, nil
			}}
			stream := &fakeServerStream{requests: []*serverv1.AttestRequest{payload}, recvErr: tc.recvErr, sendErrAt: tc.sendErrAt}
			if tc.recvErr == nil {
				if tc.wrongProof {
					stream.requests = append(stream.requests, payload)
				} else {
					stream.requests = append(stream.requests, proof)
				}
			}
			err := plugin.Attest(stream)
			if err == nil || closes != 1 {
				t.Fatalf("error=%v closes=%d", err, closes)
			}
			if strings.Contains(err.Error(), "synthetic-secret-nonce") {
				t.Fatal("proof error exposed request data")
			}
			if tc.verifyErr && status.Code(err) != codes.Unauthenticated {
				t.Fatalf("proof error status: %v", err)
			}
			if tc.verifyErr && stream.sends != 1 {
				t.Fatal("failed proof returned agent attributes")
			}
		})
	}
}

type fakeAgentAttempt struct {
	closed     bool
	respondErr error
}

func (*fakeAgentAttempt) Payload() []byte { return []byte("synthetic-payload") }
func (a *fakeAgentAttempt) Respond(context.Context, []byte) ([]byte, error) {
	return []byte("synthetic-proof"), a.respondErr
}
func (a *fakeAgentAttempt) Close() { a.closed = true }

type fakeAgentStream struct {
	grpc.ServerStream
	ctx         context.Context
	blockRecv   bool
	payloadSent chan struct{}
	attempt     *fakeAgentAttempt
	receives    int
	sends       int
	sendErrAt   int
	recvErr     error
}

func (s *fakeAgentStream) Context() context.Context {
	if s.ctx != nil {
		return s.ctx
	}
	return context.Background()
}
func (s *fakeAgentStream) Recv() (*agentv1.Challenge, error) {
	if s.blockRecv {
		<-s.Context().Done()
		return nil, s.Context().Err()
	}
	s.receives++
	if s.receives == 1 && s.recvErr == nil {
		return &agentv1.Challenge{Challenge: []byte("synthetic-challenge")}, nil
	}
	if s.attempt.closed {
		return nil, errors.New("attempt closed before SPIRE finished verification")
	}
	if s.recvErr != nil {
		return nil, s.recvErr
	}
	return nil, io.EOF
}
func (s *fakeAgentStream) Send(response *agentv1.PayloadOrChallengeResponse) error {
	s.sends++
	if s.sends == 1 && s.payloadSent != nil {
		close(s.payloadSent)
	}
	if s.sends == s.sendErrAt {
		return io.ErrClosedPipe
	}
	if s.sends == 1 && string(response.GetPayload()) != "synthetic-payload" {
		return errors.New("invalid first payload")
	}
	if s.sends == 2 && string(response.GetChallengeResponse()) != "synthetic-proof" {
		return errors.New("invalid proof response")
	}
	return nil
}

func TestAgentStreamCancellationReleasesAttempt(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	attempt := new(fakeAgentAttempt)
	stream := &fakeAgentStream{ctx: ctx, blockRecv: true, payloadSent: make(chan struct{}), attempt: attempt}
	completed := make(chan error, 1)
	go func() {
		completed <- aidAttestation(stream, AgentConfig{}, func(AgentConfig) (agentPluginAttempt, error) { return attempt, nil })
	}()
	select {
	case <-stream.payloadSent:
	case <-time.After(5 * time.Second):
		t.Fatal("agent did not send the payload")
	}
	cancel()
	select {
	case err := <-completed:
		if status.Code(err) != codes.Canceled || !attempt.closed {
			t.Fatalf("cancellation error=%v closed=%v", err, attempt.closed)
		}
	case <-time.After(5 * time.Second):
		t.Fatal("canceled agent attempt did not close")
	}
}

func TestAgentAttemptLifecycle(t *testing.T) {
	for _, tc := range []struct {
		name       string
		sendErrAt  int
		recvErr    error
		respondErr error
	}{
		{name: "success"},
		{name: "payload send error", sendErrAt: 1},
		{name: "proof send error", sendErrAt: 2},
		{name: "challenge receive error", recvErr: io.ErrUnexpectedEOF},
		{name: "SPIRE closes stream", recvErr: io.EOF},
		{name: "proof error", respondErr: errors.New("synthetic-secret-nonce")},
	} {
		t.Run(tc.name, func(t *testing.T) {
			attempt := &fakeAgentAttempt{respondErr: tc.respondErr}
			stream := &fakeAgentStream{attempt: attempt, sendErrAt: tc.sendErrAt, recvErr: tc.recvErr}
			err := aidAttestation(stream, AgentConfig{}, func(AgentConfig) (agentPluginAttempt, error) { return attempt, nil })
			wantError := tc.sendErrAt != 0 || tc.respondErr != nil || (tc.recvErr != nil && !errors.Is(tc.recvErr, io.EOF))
			if (err != nil) != wantError || !attempt.closed {
				t.Fatalf("error=%v closed=%v", err, attempt.closed)
			}
			if err != nil && strings.Contains(err.Error(), "synthetic-secret-nonce") {
				t.Fatal("proof error exposed request data")
			}
			if tc.name == "success" && (stream.sends != 2 || stream.receives != 2) {
				t.Fatal("agent did not wait for SPIRE stream completion")
			}
		})
	}
}

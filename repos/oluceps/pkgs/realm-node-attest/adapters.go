package nodeattest

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"os"
	"sync"
	"time"

	"github.com/hashicorp/hcl"
	agentv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/agent/nodeattestor/v1"
	serverv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/server/nodeattestor/v1"
	configv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/service/common/config/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

var (
	_ agentv1.NodeAttestorServer  = (*AgentPlugin)(nil)
	_ serverv1.NodeAttestorServer = (*ServerPlugin)(nil)
	_ configv1.ConfigServer       = (*AgentPlugin)(nil)
	_ configv1.ConfigServer       = (*ServerPlugin)(nil)
)

// AgentPlugin implements the agent NodeAttestor registered as http_fqdn in SPIRE.
type AgentPlugin struct {
	agentv1.UnimplementedNodeAttestorServer
	configv1.UnimplementedConfigServer

	mu       sync.RWMutex
	config   *AgentConfig
	metrics  *metricsRegistry
	listener metricsListener
}

// Configure replaces the agent configuration only after all checks pass.
func (p *AgentPlugin) Configure(_ context.Context, req *configv1.ConfigureRequest) (*configv1.ConfigureResponse, error) {
	var cfg AgentConfig
	if err := readPluginConfig(req, &cfg); err != nil {
		return nil, err
	}
	if err := checkTrustDomain(req, cfg.TrustDomain); err != nil {
		return nil, err
	}
	if err := validateAgentConfig(cfg); err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid agent configuration")
	}

	p.mu.Lock()
	defer p.mu.Unlock()
	if p.metrics == nil {
		p.metrics = newMetrics("agent")
	}
	if err := p.listener.configure(cfg.MetricsAddress, p.metrics); err != nil {
		return nil, status.Error(codes.InvalidArgument, "cannot configure metrics listener")
	}
	p.metrics.register(cfg.FQDN)
	p.config = &cfg
	return &configv1.ConfigureResponse{}, nil
}

// AidAttestation keeps one configuration snapshot for the entire stream.
func (p *AgentPlugin) AidAttestation(stream agentv1.NodeAttestor_AidAttestationServer) error {
	p.mu.Lock()
	if p.metrics == nil {
		p.metrics = newMetrics("agent")
	}
	cfg, metrics := p.config, p.metrics
	p.mu.Unlock()
	if cfg == nil {
		metrics.record("unknown", "failure", "start", "not_configured", 0)
		return status.Error(codes.FailedPrecondition, "plugin is not configured")
	}
	return aidAttestation(stream, *cfg, func(cfg AgentConfig) (agentPluginAttempt, error) {
		return BeginAgent(cfg)
	}, metrics)
}

type agentPluginAttempt interface {
	Payload() []byte
	Respond(context.Context, []byte) ([]byte, error)
	Close()
}

func aidAttestation(stream agentv1.NodeAttestor_AidAttestationServer, cfg AgentConfig, begin func(AgentConfig) (agentPluginAttempt, error), registries ...*metricsRegistry) (retErr error) {
	var metrics *metricsRegistry
	if len(registries) != 0 {
		metrics = registries[0]
	}
	start := time.Now()
	outcome, stage, reason := "failure", "start", "internal"
	submitted := false
	metrics.pendingAdd(cfg.FQDN, 1)
	defer func() {
		metrics.pendingAdd(cfg.FQDN, -1)
		if submitted {
			return
		}
		if retErr != nil {
			stage, reason = classifyError(stream.Context(), retErr, stage, reason)
		}
		metrics.record(cfg.FQDN, outcome, stage, reason, time.Since(start))
	}()
	ctx, cancel := context.WithTimeout(stream.Context(), 120*time.Second)
	defer cancel()
	attempt, err := begin(cfg)
	if err != nil {
		return attestationError(ctx, codes.Internal, "cannot start agent attestation")
	}
	defer attempt.Close()

	stage, reason = "payload", "stream_error"
	if err := stream.Send(&agentv1.PayloadOrChallengeResponse{
		Data: &agentv1.PayloadOrChallengeResponse_Payload{Payload: attempt.Payload()},
	}); err != nil {
		return err
	}
	stage = "challenge"
	challenge, err := receiveAgentChallenge(ctx, stream)
	if err != nil {
		if errors.Is(err, io.EOF) {
			outcome, reason = "skipped", "no_challenge"
			return nil
		}
		return err
	}
	reason = "invalid_challenge"
	if challenge == nil || len(challenge.Challenge) == 0 {
		return status.Error(codes.InvalidArgument, "challenge is required")
	}
	response, err := attempt.Respond(ctx, challenge.Challenge)
	if err != nil {
		stage, reason = classifyError(ctx, err, stage, reason)
		return attestationError(ctx, codes.Unauthenticated, "cannot answer attestation challenge")
	}
	stage, reason = "response", "stream_error"
	sendContextErr := ctx.Err()
	if err := stream.Send(&agentv1.PayloadOrChallengeResponse{
		Data: &agentv1.PayloadOrChallengeResponse_ChallengeResponse{ChallengeResponse: response},
	}); err != nil {
		return err
	}
	// Send success is a local proof submission, not server verification or issuance.
	// Core can cancel the stream after it consumes this response.
	if sendContextErr == nil {
		submitted = true
		metrics.record(cfg.FQDN, "success", "response", "proof_submitted", time.Since(start))
	}
	// Keep the proof and preserve RPC error returns until Core closes the stream.
	if _, err := receiveAgentChallenge(ctx, stream); err != nil {
		if errors.Is(err, io.EOF) {
			return nil
		}
		return err
	}
	return status.Error(codes.InvalidArgument, "unexpected additional challenge")
}

type serverPluginAttempt interface {
	Context() context.Context
	Challenge() []byte
	Verify(context.Context, []byte) (*Result, error)
	Close()
}

type serverPluginBegin func(context.Context, []byte) (serverPluginAttempt, error)

// ServerPlugin implements the server NodeAttestor registered as http_fqdn in SPIRE.
type ServerPlugin struct {
	serverv1.UnimplementedNodeAttestorServer
	configv1.UnimplementedConfigServer

	mu       sync.RWMutex
	begin    serverPluginBegin
	nodes    map[string]node
	metrics  *metricsRegistry
	listener metricsListener
}

// Configure validates a new server before it replaces the active server.
func (p *ServerPlugin) Configure(_ context.Context, req *configv1.ConfigureRequest) (*configv1.ConfigureResponse, error) {
	var cfg ServerConfig
	if err := readPluginConfig(req, &cfg); err != nil {
		return nil, err
	}
	if err := checkTrustDomain(req, cfg.TrustDomain); err != nil {
		return nil, err
	}
	server, err := NewServer(cfg)
	if err != nil {
		return nil, status.Error(codes.InvalidArgument, "invalid server configuration")
	}
	begin := func(ctx context.Context, payload []byte) (serverPluginAttempt, error) {
		return server.Begin(ctx, payload)
	}

	p.mu.Lock()
	defer p.mu.Unlock()
	if p.metrics == nil {
		p.metrics = newMetrics("server")
	}
	if err := p.listener.configure(cfg.MetricsAddress, p.metrics); err != nil {
		return nil, status.Error(codes.InvalidArgument, "cannot configure metrics listener")
	}
	for _, n := range server.nodes {
		p.metrics.register(n.name)
	}
	p.metrics.mu.Lock()
	p.metrics.capacity = 32
	p.metrics.mu.Unlock()
	server.metrics = p.metrics
	p.nodes = server.nodes
	p.begin = begin
	return &configv1.ConfigureResponse{}, nil
}

// Attest uses a separate attempt for each stream and closes it on every exit.
func (p *ServerPlugin) Attest(stream serverv1.NodeAttestor_AttestServer) (retErr error) {
	p.mu.Lock()
	if p.metrics == nil {
		p.metrics = newMetrics("server")
	}
	begin, nodes, metrics := p.begin, p.nodes, p.metrics
	p.mu.Unlock()
	start := time.Now()
	metricNode, outcome, stage, reason := "unknown", "failure", "start", "not_configured"
	defer func() {
		if retErr != nil {
			stage, reason = classifyError(stream.Context(), retErr, stage, reason)
		}
		metrics.record(metricNode, outcome, stage, reason, time.Since(start))
	}()
	if begin == nil {
		return status.Error(codes.FailedPrecondition, "plugin is not configured")
	}

	stage, reason = "payload", "stream_error"
	message, err := stream.Recv()
	if err != nil {
		return err
	}
	reason = "invalid_payload"
	payload, ok := message.GetRequest().(*serverv1.AttestRequest_Payload)
	if !ok || len(payload.Payload) == 0 {
		return status.Error(codes.InvalidArgument, "attestation payload is required")
	}
	// Resolve labels only through this stream's configured registry snapshot.
	var claim request
	if decodeJSON(payload.Payload, &claim) == nil {
		if n, ok := nodes[claim.FQDN]; ok {
			metricNode = n.name
		}
	}
	attempt, err := begin(stream.Context(), payload.Payload)
	if err != nil {
		stage, reason = classifyError(stream.Context(), err, stage, reason)
		return attestationError(stream.Context(), codes.Unauthenticated, "cannot start server attestation")
	}
	defer attempt.Close()

	stage, reason = "challenge", "stream_error"
	if err := stream.Send(&serverv1.AttestResponse{
		Response: &serverv1.AttestResponse_Challenge{Challenge: attempt.Challenge()},
	}); err != nil {
		return err
	}
	stage = "response"
	message, err = receiveServerResponse(attempt.Context(), stream)
	if err != nil {
		stage, reason = classifyError(attempt.Context(), err, stage, reason)
		return err
	}
	reason = "invalid_response"
	response, ok := message.GetRequest().(*serverv1.AttestRequest_ChallengeResponse)
	if !ok || len(response.ChallengeResponse) == 0 {
		return status.Error(codes.InvalidArgument, "challenge response is required")
	}
	stage, reason = "verify", "invalid_proof"
	result, err := attempt.Verify(stream.Context(), response.ChallengeResponse)
	if err != nil {
		stage, reason = classifyError(attempt.Context(), err, stage, reason)
		return attestationError(stream.Context(), codes.Unauthenticated, "attestation verification failed")
	}
	stage, reason = "attributes", "invalid_result"
	if result == nil || result.AgentID == "" {
		return status.Error(codes.Internal, "attestation result has no agent ID")
	}
	reason = "stream_error"
	if err := stream.Send(&serverv1.AttestResponse{
		Response: &serverv1.AttestResponse_AgentAttributes{
			AgentAttributes: &serverv1.AgentAttributes{
				SpiffeId:       result.AgentID,
				SelectorValues: result.SelectorValues,
				CanReattest:    true,
			},
		},
	}); err != nil {
		return err
	}
	outcome, reason = "success", "attributes_sent"
	return nil
}

// Close releases the optional listener when the plugin process stops.
func (p *AgentPlugin) Close() error {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.listener.close()
}

func (p *ServerPlugin) Close() error {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.listener.close()
}

// A buffered channel lets Recv finish after the handler returns and gRPC cancels it.
func receiveServerResponse(ctx context.Context, stream serverv1.NodeAttestor_AttestServer) (*serverv1.AttestRequest, error) {
	return receivePluginMessage(ctx, stream.Context(), stream.Recv)
}

func receiveAgentChallenge(ctx context.Context, stream agentv1.NodeAttestor_AidAttestationServer) (*agentv1.Challenge, error) {
	return receivePluginMessage(ctx, stream.Context(), stream.Recv)
}

func receivePluginMessage[T any](ctx, streamCtx context.Context, recv func() (T, error)) (T, error) {
	var empty T
	if err := ctx.Err(); err != nil {
		return empty, status.FromContextError(err).Err()
	}
	if err := streamCtx.Err(); err != nil {
		return empty, status.FromContextError(err).Err()
	}
	type result struct {
		message T
		err     error
	}
	completed := make(chan result, 1)
	go func() {
		message, err := recv()
		completed <- result{message: message, err: err}
	}()
	select {
	case <-ctx.Done():
		return empty, status.FromContextError(ctx.Err()).Err()
	case <-streamCtx.Done():
		return empty, status.FromContextError(streamCtx.Err()).Err()
	case result := <-completed:
		if err := ctx.Err(); err != nil {
			return empty, status.FromContextError(err).Err()
		}
		if err := streamCtx.Err(); err != nil {
			return empty, status.FromContextError(err).Err()
		}
		return result.message, result.err
	}
}

func readPluginConfig(req *configv1.ConfigureRequest, target any) error {
	if req == nil {
		return status.Error(codes.InvalidArgument, "configuration is required")
	}
	var pluginData struct {
		ConfigFile string `hcl:"config_file"`
	}
	if err := hcl.Decode(&pluginData, req.HclConfiguration); err != nil {
		return status.Error(codes.InvalidArgument, "invalid plugin_data HCL")
	}
	if pluginData.ConfigFile == "" {
		return status.Error(codes.InvalidArgument, "config_file is required")
	}
	file, err := os.Open(pluginData.ConfigFile)
	if err != nil {
		return status.Error(codes.InvalidArgument, "cannot open config_file")
	}
	defer file.Close()
	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return status.Error(codes.InvalidArgument, "invalid config_file JSON")
	}
	if err := decoder.Decode(new(any)); !errors.Is(err, io.EOF) {
		return status.Error(codes.InvalidArgument, "config_file must contain one JSON object")
	}
	return nil
}

func checkTrustDomain(req *configv1.ConfigureRequest, trustDomain string) error {
	if trustDomain == "" || req.GetCoreConfiguration().GetTrustDomain() != trustDomain {
		return status.Error(codes.InvalidArgument, "JSON trust_domain must match the SPIRE trust domain")
	}
	return nil
}

// Core errors can contain request data. Return fixed text so SPIRE logs no proof data.
func attestationError(ctx context.Context, code codes.Code, message string) error {
	if err := ctx.Err(); err != nil {
		return status.FromContextError(err).Err()
	}
	return status.Error(code, message)
}

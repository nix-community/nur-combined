package main

import (
	"bytes"
	"context"
	"crypto/x509"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"strings"
	"testing"
	"time"

	workload "github.com/spiffe/go-spiffe/v2/proto/spiffe/workload"
	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"google.golang.org/grpc"
)

type testWorkloadServer struct {
	workload.UnimplementedSpiffeWorkloadAPIServer
	reply   *workload.X509SVIDResponse
	entered chan struct{}
}

func (s *testWorkloadServer) FetchX509SVID(_ *workload.X509SVIDRequest, stream grpc.ServerStreamingServer[workload.X509SVIDResponse]) error {
	if s.entered != nil {
		close(s.entered)
	}
	if s.reply != nil {
		if err := stream.Send(s.reply); err != nil {
			return err
		}
	}
	<-stream.Context().Done()
	return stream.Context().Err()
}
func startWorkloadAPI(t *testing.T, service *testWorkloadServer) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "workload.sock")
	listener, err := net.Listen("unix", path)
	if err != nil {
		t.Fatal("listen test Workload API")
	}
	server := grpc.NewServer()
	workload.RegisterSpiffeWorkloadAPIServer(server, service)
	done := make(chan struct{})
	go func() { defer close(done); _ = server.Serve(listener) }()
	t.Cleanup(func() { server.Stop(); _ = listener.Close(); <-done })
	return path
}
func TestWorkloadAPIExportsOnlyOwnCanary(t *testing.T) {
	c := testConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	makeSVID := func(id string) *workload.X509SVID {
		cert, leaf := ca.leaf(t, []string{id}, now.Add(-time.Minute), now.Add(time.Minute))
		key, err := x509.MarshalPKCS8PrivateKey(cert.PrivateKey)
		if err != nil {
			t.Fatal("encode in-memory test key")
		}
		return &workload.X509SVID{SpiffeId: id, X509Svid: leaf.Raw, X509SvidKey: key, Bundle: ca.cert.Raw}
	}
	own := makeSVID(c.canaryID())
	other := makeSVID("spiffe://example.org/service/other")
	c.WorkloadSocket = startWorkloadAPI(t, &testWorkloadServer{reply: &workload.X509SVIDResponse{Svids: []*workload.X509SVID{other, own}}})
	e := newExporter(c, nil)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	o := e.collectCanary(ctx)
	e.record(o)
	if o.err != nil {
		t.Fatal("fetch own canary from Workload API")
	}
	var b bytes.Buffer
	e.metrics(&b, time.Now())
	output := b.String()
	if !strings.Contains(output, c.canaryID()) || strings.Contains(output, other.SpiffeId) || strings.Contains(output, "PRIVATE KEY") || bytes.Contains(b.Bytes(), own.X509SvidKey) || bytes.Contains(b.Bytes(), other.X509SvidKey) {
		t.Fatal("Workload API exposition contains more than own public metadata")
	}
}
func TestHTTPAvailableBeforeWorkloadAPIResponse(t *testing.T) {
	c := testConfig()
	entered := make(chan struct{})
	c.WorkloadSocket = startWorkloadAPI(t, &testWorkloadServer{entered: entered})
	c.BundlePath = filepath.Join(t.TempDir(), "missing.pem")
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal("listen exporter")
	}
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	logger := slog.New(slog.NewJSONHandler(io.Discard, nil))
	done := make(chan error, 1)
	go func() { done <- serveListener(ctx, c, logger, listener) }()
	defer func() {
		cancel()
		select {
		case err := <-done:
			if err != nil {
				t.Error("serve failed")
			}
		case <-time.After(time.Second):
			t.Error("shutdown did not cancel collection")
		}
	}()
	select {
	case <-entered:
	case <-time.After(time.Second):
		t.Fatal("Workload API request did not start")
	}
	client := &http.Client{Timeout: time.Second}
	response, err := client.Get("http://" + listener.Addr().String() + "/metrics")
	if err != nil {
		t.Fatal("HTTP blocked on Workload API")
	}
	defer response.Body.Close()
	raw, err := io.ReadAll(response.Body)
	if err != nil || response.StatusCode != 200 {
		t.Fatal("metrics unavailable during Workload API wait")
	}
	if !strings.Contains(string(raw), `realm_identity_collector_success{node="eihort",collector="canary"} 0`) || !strings.Contains(string(raw), `realm_identity_collector_last_success_timestamp_seconds{node="eihort",collector="canary"} 0`) {
		t.Fatal("initial pending collector reported success")
	}
	health, err := client.Get("http://" + listener.Addr().String() + "/healthz")
	if err != nil {
		t.Fatal("health HTTP blocked on Workload API")
	}
	defer health.Body.Close()
	if health.StatusCode != 503 {
		t.Fatal("pending collector reported healthy")
	}
}

func TestWorkloadCycleUsesOwnAPICredentialsAndKeepsEnvoyIndependent(t *testing.T) {
	c := holderConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(2*time.Hour))
	observer := observerCredentials(t, ca, c)
	c.Workloads[0].Source = sourceCaddy
	serverCert, _ := ca.leaf(t, []string{c.Workloads[0].Identity}, now.Add(-time.Minute), now.Add(time.Hour))
	c.Workloads[0].Address = serveHolderTLS(t, serverCert, observer.Bundle, tlsconfig.AuthorizeID(spiffeid.RequireFromString(c.canaryID())), http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" || r.URL.Path != "/" {
			t.Error("wrong Caddy request")
		}
		w.WriteHeader(204)
	}))
	envoyTarget := WorkloadTarget{Unit: "realm-internet.service", Identity: "spiffe://example.org/service/internet", Source: sourceEnvoy}
	envoyBody := envoyJSON("1", now.Add(-time.Minute).UTC().Format(time.RFC3339), now.Add(time.Hour).UTC().Format(time.RFC3339), envoyTarget.Identity)
	envoy := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" || r.URL.Path != "/certs" {
			t.Error("wrong Envoy request")
		}
		_, _ = w.Write(envoyBody)
	}))
	defer envoy.Close()
	envoyTarget.Address = strings.TrimPrefix(envoy.URL, "http://")
	c.Workloads = append(c.Workloads, envoyTarget)
	ownKey, err := x509.MarshalPKCS8PrivateKey(observer.SVID.PrivateKey)
	if err != nil {
		t.Fatal("encode in-memory observer key")
	}
	otherCert, otherLeaf := ca.leaf(t, []string{c.Workloads[0].Identity}, now.Add(-time.Minute), now.Add(time.Hour))
	otherKey, err := x509.MarshalPKCS8PrivateKey(otherCert.PrivateKey)
	if err != nil {
		t.Fatal("encode in-memory other key")
	}
	c.WorkloadSocket = startWorkloadAPI(t, &testWorkloadServer{reply: &workload.X509SVIDResponse{Svids: []*workload.X509SVID{
		{SpiffeId: c.Workloads[0].Identity, X509Svid: otherLeaf.Raw, X509SvidKey: otherKey, Bundle: ca.cert.Raw},
		{SpiffeId: c.canaryID(), X509Svid: observer.Cert.Raw, X509SvidKey: ownKey, Bundle: ca.cert.Raw},
	}}})
	wrongCA := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	c.BundlePath = bundleFile(t, wrongCA.cert)
	c.ServerAddress = "127.0.0.1:1"
	e := newExporter(c, nil)
	e.command = func(context.Context, string, ...string) ([]byte, error) { return activityJSON(c.Workloads), nil }
	e.collect(context.Background())
	if !e.states["canary"].success || !e.holders[c.Workloads[0].Unit].success || !e.holders[envoyTarget.Unit].success || e.states["bootstrap"].success {
		t.Fatal("observer context, holder trust, or bootstrap isolation failed")
	}
	var b bytes.Buffer
	e.metrics(&b, time.Now())
	if bytes.Contains(b.Bytes(), ownKey) || bytes.Contains(b.Bytes(), otherKey) || strings.Contains(b.String(), "PRIVATE KEY") {
		t.Fatal("observer key reached metrics")
	}
	previous := e.holders[c.Workloads[0].Unit].observed
	e.fetch = func(ctx context.Context, _ Config) (canaryMetadata, error) {
		<-ctx.Done()
		return canaryMetadata{}, ctx.Err()
	}
	ctx, cancel := context.WithTimeout(context.Background(), 80*time.Millisecond)
	defer cancel()
	e.collect(ctx)
	holder := e.holders[c.Workloads[0].Unit]
	if holder.success || holder.dormant || !holder.observed.Equal(previous) || !e.holders[envoyTarget.Unit].success {
		t.Fatal("Workload API failure did not isolate TLS holders from local Envoy metadata")
	}
	b.Reset()
	e.metrics(&b, time.Now())
	if strings.Contains(b.String(), fmt.Sprintf(`realm_workload_svid_not_after_seconds{node="eihort",unit="%s"`, c.Workloads[0].Unit)) {
		t.Fatal("failed TLS observation retained old certificate")
	}
}

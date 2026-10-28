package main

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/pem"
	"math/big"
	"net"
	"net/url"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/svid/x509svid"
)

type testCA struct {
	cert *x509.Certificate
	key  *ecdsa.PrivateKey
}

func newCA(t *testing.T, notBefore, notAfter time.Time) testCA {
	t.Helper()
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatal("generate CA key")
	}
	template := &x509.Certificate{SerialNumber: randomSerial(t), Subject: pkix.Name{CommonName: "test CA"}, NotBefore: notBefore, NotAfter: notAfter, IsCA: true, BasicConstraintsValid: true, KeyUsage: x509.KeyUsageCertSign | x509.KeyUsageCRLSign}
	raw, err := x509.CreateCertificate(rand.Reader, template, template, &key.PublicKey, key)
	if err != nil {
		t.Fatal("create CA certificate")
	}
	cert, err := x509.ParseCertificate(raw)
	if err != nil {
		t.Fatal("parse CA certificate")
	}
	return testCA{cert, key}
}
func randomSerial(t *testing.T) *big.Int {
	t.Helper()
	serial, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 120))
	if err != nil {
		t.Fatal("generate serial")
	}
	return serial
}
func (ca testCA) leaf(t *testing.T, ids []string, notBefore, notAfter time.Time) (tls.Certificate, *x509.Certificate) {
	t.Helper()
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatal("generate leaf key")
	}
	template := &x509.Certificate{SerialNumber: randomSerial(t), NotBefore: notBefore, NotAfter: notAfter, KeyUsage: x509.KeyUsageDigitalSignature, ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth, x509.ExtKeyUsageClientAuth}, BasicConstraintsValid: true}
	for _, id := range ids {
		uri, err := url.Parse(id)
		if err != nil {
			t.Fatal("parse test URI")
		}
		template.URIs = append(template.URIs, uri)
	}
	raw, err := x509.CreateCertificate(rand.Reader, template, ca.cert, &key.PublicKey, ca.key)
	if err != nil {
		t.Fatal("create leaf certificate")
	}
	cert, err := x509.ParseCertificate(raw)
	if err != nil {
		t.Fatal("parse leaf certificate")
	}
	// The test keeps all private keys in memory.
	return tls.Certificate{Certificate: [][]byte{raw}, PrivateKey: key, Leaf: cert}, cert
}
func bundleFile(t *testing.T, certs ...*x509.Certificate) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "bundle.pem")
	var raw []byte
	for _, cert := range certs {
		raw = append(raw, pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: cert.Raw})...)
	}
	if os.WriteFile(path, raw, 0600) != nil {
		t.Fatal("write public bundle")
	}
	return path
}
func testConfig() Config {
	return Config{Node: "eihort", TrustDomain: "example.org", ListenAddress: "127.0.0.1:18494", BundlePath: "/public/bundle.pem", ServerAddress: "eihort.nyaw.xyz:8081", WorkloadSocket: "/run/spire/agent/public/api.sock"}
}
func startTLS(t *testing.T, cert tls.Certificate, maxVersion uint16) string {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal("listen TLS")
	}
	var wg sync.WaitGroup
	done := make(chan struct{})
	go func() {
		defer close(done)
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			wg.Add(1)
			go func() {
				defer wg.Done()
				defer conn.Close()
				_ = conn.SetDeadline(time.Now().Add(2 * time.Second))
				s := tls.Server(conn, &tls.Config{Certificates: []tls.Certificate{cert}, MinVersion: tls.VersionTLS12, MaxVersion: maxVersion})
				_ = s.Handshake()
			}()
		}
	}()
	t.Cleanup(func() { _ = listener.Close(); <-done; wg.Wait() })
	return listener.Addr().String()
}
func TestBootstrapPinnedTrust(t *testing.T) {
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(24*time.Hour))
	wrong := newCA(t, now.Add(-time.Hour), now.Add(48*time.Hour))
	expired := newCA(t, now.Add(-48*time.Hour), now.Add(-time.Hour))
	tests := []struct {
		name          string
		signer        testCA
		roots         []*x509.Certificate
		ids           []string
		before, after time.Time
		version       uint16
		valid         bool
	}{
		{"valid", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, true},
		{"wrong_ca", ca, []*x509.Certificate{wrong.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"expired_root", expired, []*x509.Certificate{expired.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(-2 * time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"expired_leaf", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(-2 * time.Hour), now.Add(-time.Minute), tls.VersionTLS13, false},
		{"future_leaf", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(time.Hour), now.Add(2 * time.Hour), tls.VersionTLS13, false},
		{"wrong_uri", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/not-server"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"wrong_domain", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://other.org/spire/server"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"no_uri", ca, []*x509.Certificate{ca.cert}, nil, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"multiple_uris", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/server", "spiffe://example.org/other"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"uri_query", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/server?foo=bar"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
		{"tls12", ca, []*x509.Certificate{ca.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(-time.Hour), now.Add(time.Hour), tls.VersionTLS12, false},
		{"unrelated_later_root", expired, []*x509.Certificate{expired.cert, wrong.cert}, []string{"spiffe://example.org/spire/server"}, now.Add(-2 * time.Hour), now.Add(time.Hour), tls.VersionTLS13, false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cert, _ := tt.signer.leaf(t, tt.ids, tt.before, tt.after)
			c := testConfig()
			c.ServerAddress = startTLS(t, cert, tt.version)
			c.BundlePath = bundleFile(t, tt.roots...)
			roots, err := loadBundle(c.BundlePath)
			if err != nil {
				t.Fatal("load test bundle")
			}
			ctx, cancel := context.WithTimeout(context.Background(), time.Second)
			defer cancel()
			until, probeErr := probeBootstrap(ctx, c, roots)
			err = probeErr
			if tt.valid && !until.Equal(tt.after.Truncate(time.Second)) {
				t.Fatal("verified chain validity bound missing")
			}
			if (err == nil) != tt.valid {
				t.Fatalf("handshake valid=%t, want %t", err == nil, tt.valid)
			}
		})
	}
}
func TestBootstrapFailureAndTimeout(t *testing.T) {
	c := testConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal("listen")
	}
	c.ServerAddress = listener.Addr().String()
	var conn net.Conn
	accepted := make(chan struct{})
	go func() { conn, _ = listener.Accept(); close(accepted) }()
	ctx, cancel := context.WithTimeout(context.Background(), 40*time.Millisecond)
	defer cancel()
	start := time.Now()
	_, err = probeBootstrap(ctx, c, []*x509.Certificate{ca.cert})
	<-accepted
	if conn != nil {
		_ = conn.Close()
	}
	_ = listener.Close()
	if err == nil || time.Since(start) > time.Second {
		t.Fatal("handshake timeout did not fail promptly")
	}
	ctx2, cancel2 := context.WithTimeout(context.Background(), time.Second)
	defer cancel2()
	if _, err := probeBootstrap(ctx2, c, []*x509.Certificate{ca.cert}); err == nil {
		t.Fatal("closed endpoint passed")
	}
}
func TestBundleInventoryAndFormat(t *testing.T) {
	now := time.Now()
	active := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	old := newCA(t, now.Add(-2*time.Hour), now.Add(-time.Hour))
	c := testConfig()
	c.BundlePath = bundleFile(t, active.cert, old.cert, active.cert)
	c.ServerAddress = "127.0.0.1:1"
	e := newExporter(c, nil)
	e.collectBootstrap(context.Background())
	e.mu.RLock()
	bundle := e.states["bundle"]
	bootstrap := e.states["bootstrap"]
	e.mu.RUnlock()
	if !bundle.success || bootstrap.success {
		t.Fatal("bundle inventory became server trust")
	}
	counts := map[string]float64{}
	for _, s := range bundle.samples {
		counts[s.name] = s.value
	}
	if counts["realm_bootstrap_bundle_certificates"] != 2 || counts["realm_bootstrap_bundle_active_valid_certificates"] != 1 {
		t.Fatal("incorrect bundle counts")
	}
	for _, raw := range [][]byte{nil, []byte("garbage"), append([]byte("-----BEGIN CERTIFICATE-----\ninvalid\n"), pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: active.cert.Raw})...), pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: []byte("not a key")}), append(pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: active.cert.Raw}), []byte("garbage")...)} {
		path := filepath.Join(t.TempDir(), "invalid.pem")
		if os.WriteFile(path, raw, 0600) != nil {
			t.Fatal("write invalid public fixture")
		}
		if _, err := loadBundle(path); err == nil {
			t.Fatal("invalid bundle passed")
		}
	}
}
func TestOwnCanaryOnly(t *testing.T) {
	c := testConfig()
	now := time.Now()
	ca := newCA(t, now.Add(-time.Hour), now.Add(time.Hour))
	_, cert := ca.leaf(t, []string{c.canaryID()}, now.Add(-time.Minute), now.Add(time.Minute))
	otherID := spiffeid.RequireFromString("spiffe://example.org/service/other")
	own := &x509svid.SVID{ID: spiffeid.RequireFromString(c.canaryID()), Certificates: []*x509.Certificate{cert}}
	other := &x509svid.SVID{ID: otherID, Certificates: []*x509.Certificate{cert}}
	if _, err := selectCanary(c, []*x509svid.SVID{other}, now); err == nil {
		t.Fatal("other workload accepted")
	}
	got, err := selectCanary(c, []*x509svid.SVID{other, own}, now)
	if err != nil || got.Cert != cert {
		t.Fatal("own canary missing")
	}
	if _, err := selectCanary(c, []*x509svid.SVID{own, own}, now); err == nil {
		t.Fatal("ambiguous canary accepted")
	}
	if _, err := selectCanary(c, []*x509svid.SVID{own}, now.Add(time.Hour)); err == nil {
		t.Fatal("expired canary accepted")
	}
	_, wrongCert := ca.leaf(t, []string{otherID.String()}, now.Add(-time.Minute), now.Add(time.Minute))
	own.Certificates = []*x509.Certificate{wrongCert}
	if _, err := selectCanary(c, []*x509svid.SVID{own}, now); err == nil {
		t.Fatal("wrong leaf URI accepted")
	}
}

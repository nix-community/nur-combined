package main

import (
	"bytes"
	"context"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/pem"
	"errors"
	"net"
	"time"

	"github.com/spiffe/go-spiffe/v2/bundle/x509bundle"
	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/svid/x509svid"
	"github.com/spiffe/go-spiffe/v2/workloadapi"
)

const maxBundleBytes = 1 << 20

func loadBundle(path string) ([]*x509.Certificate, error) {
	raw, err := readPublicFile(path, maxBundleBytes)
	if err != nil {
		return nil, errors.New("bundle_read")
	}
	var certs []*x509.Certificate
	seen := map[string]bool{}
	for len(raw) > 0 {
		// Reject text, unknown PEM blocks, private keys, and incomplete PEM data.
		raw = trimSpace(raw)
		if len(raw) == 0 {
			break
		}
		if len(raw) < 27 || string(raw[:27]) != "-----BEGIN CERTIFICATE-----" {
			return nil, errors.New("bundle_format")
		}
		block, rest := pem.Decode(raw)
		if block == nil || block.Type != "CERTIFICATE" || len(block.Headers) != 0 || bytes.Count(raw[:len(raw)-len(rest)], []byte("-----BEGIN ")) != 1 {
			return nil, errors.New("bundle_format")
		}
		cert, err := x509.ParseCertificate(block.Bytes)
		if err != nil || !cert.IsCA || !cert.BasicConstraintsValid || cert.KeyUsage&x509.KeyUsageCertSign == 0 {
			return nil, errors.New("bundle_certificate")
		}
		fp := fingerprint(cert)
		if !seen[fp] {
			certs = append(certs, cert)
			seen[fp] = true
		}
		if len(certs) > 64 {
			return nil, errors.New("bundle_limit")
		}
		raw = rest
	}
	if len(certs) == 0 {
		return nil, errors.New("bundle_empty")
	}
	return certs, nil
}
func trimSpace(raw []byte) []byte {
	for len(raw) > 0 && (raw[0] == ' ' || raw[0] == '\r' || raw[0] == '\n' || raw[0] == '\t') {
		raw = raw[1:]
	}
	return raw
}
func fingerprint(cert *x509.Certificate) string {
	sum := sha256.Sum256(cert.Raw)
	return hex.EncodeToString(sum[:])
}
func certCurrent(cert *x509.Certificate, now time.Time) bool {
	return !now.Before(cert.NotBefore) && now.Before(cert.NotAfter)
}

func probeBootstrap(ctx context.Context, c Config, certs []*x509.Certificate) (time.Time, error) {
	td, err := spiffeid.TrustDomainFromString(c.TrustDomain)
	if err != nil {
		return time.Time{}, errors.New("bootstrap_domain")
	}
	id, err := spiffeid.FromString("spiffe://" + c.TrustDomain + "/spire/server")
	if err != nil {
		return time.Time{}, errors.New("bootstrap_identity")
	}
	// This source contains only the configured bundle. Never use system roots or
	// the Workload API bundle for the bootstrap probe.
	var validUntil time.Time
	authorize := tlsconfig.AuthorizeID(id)
	cfg := tlsconfig.TLSClientConfig(x509bundle.FromX509Authorities(td, certs), func(peer spiffeid.ID, chains [][]*x509.Certificate) error {
		if err := authorize(peer, chains); err != nil {
			return err
		}
		if len(chains) == 0 || len(chains[0]) == 0 {
			return errors.New("bootstrap_chain")
		}
		// Bound the observation by an actual verified chain, including its root.
		for _, cert := range chains[0] {
			validUntil = earlier(validUntil, cert.NotAfter)
		}
		return nil
	})
	cfg.MinVersion = tls.VersionTLS13
	dialer := tls.Dialer{NetDialer: &net.Dialer{}, Config: cfg}
	conn, err := dialer.DialContext(ctx, "tcp", c.ServerAddress)
	if err != nil {
		if ctx.Err() != nil {
			return time.Time{}, ctx.Err()
		}
		return time.Time{}, errors.New("bootstrap_handshake")
	}
	_ = conn.Close()
	return validUntil, nil
}

type canaryMetadata struct {
	Cert   *x509.Certificate
	SVID   *x509svid.SVID
	Bundle *x509bundle.Bundle
}
type canaryFetcher func(context.Context, Config) (canaryMetadata, error)

func fetchCanary(ctx context.Context, c Config) (canaryMetadata, error) {
	client, err := workloadapi.New(ctx, workloadapi.WithAddr("unix://"+c.WorkloadSocket))
	if err != nil {
		return canaryMetadata{}, errors.New("canary_connect")
	}
	defer client.Close()
	x509ctx, err := client.FetchX509Context(ctx)
	if err != nil {
		if ctx.Err() != nil {
			return canaryMetadata{}, ctx.Err()
		}
		return canaryMetadata{}, errors.New("canary_fetch")
	}
	metadata, err := selectCanary(c, x509ctx.SVIDs, time.Now())
	if err != nil {
		return canaryMetadata{}, err
	}
	td, err := spiffeid.TrustDomainFromString(c.TrustDomain)
	if err != nil || x509ctx.Bundles == nil {
		return canaryMetadata{}, errors.New("canary_metadata")
	}
	metadata.Bundle, err = x509ctx.Bundles.GetX509BundleForTrustDomain(td)
	if err != nil || metadata.Bundle == nil {
		return canaryMetadata{}, errors.New("canary_metadata")
	}
	return metadata, nil
}
func selectCanary(c Config, svids []*x509svid.SVID, now time.Time) (canaryMetadata, error) {
	var found *x509.Certificate
	var selected *x509svid.SVID
	for _, svid := range svids {
		if svid == nil || svid.ID.String() != c.canaryID() {
			continue
		}
		if found != nil || len(svid.Certificates) == 0 {
			return canaryMetadata{}, errors.New("canary_metadata")
		}
		cert := svid.Certificates[0]
		if cert == nil {
			return canaryMetadata{}, errors.New("canary_metadata")
		}
		id, err := x509svid.IDFromCert(cert)
		if err != nil || id.String() != c.canaryID() || !certCurrent(cert, now) {
			return canaryMetadata{}, errors.New("canary_metadata")
		}
		found = cert
		selected = svid
	}
	if found == nil {
		return canaryMetadata{}, errors.New("canary_missing")
	}
	return canaryMetadata{Cert: found, SVID: selected}, nil
}

package main

import (
	"context"
	"crypto/sha256"
	"crypto/tls"
	"crypto/x509"
	"encoding/hex"
	"encoding/json"
	"errors"
	"io"
	"net"
	"net/http"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
)

const (
	sourceGhostunnel    = "ghostunnel_status_watch"
	sourceCaddy         = "caddy_loaded"
	sourceEnvoy         = "envoy_loaded"
	maxWorkloads        = 512
	workloadParallelism = 16
	maxHolderBodyBytes  = 1 << 20
)

var unitPattern = regexp.MustCompile(`^[A-Za-z0-9][A-Za-z0-9_.@:-]*\.service$`)

type WorkloadTarget struct {
	Unit     string `json:"unit"`
	Identity string `json:"identity"`
	Address  string `json:"address"`
	Source   string `json:"source"`
}

func (c Config) validateWorkloads() error {
	if len(c.Workloads) > maxWorkloads {
		return errors.New("too many workloads")
	}
	if c.SystemctlBinary != "" && (!cleanAbsolute(c.SystemctlBinary) || filepath.Base(c.SystemctlBinary) != "systemctl") {
		return errors.New("systemctl_binary must be an absolute systemctl path")
	}
	if len(c.Workloads) > 0 && c.SystemctlBinary == "" {
		return errors.New("workloads require systemctl_binary")
	}
	units, addresses := map[string]bool{}, map[string]bool{}
	for _, target := range c.Workloads {
		if len(target.Unit) > 255 || !unitPattern.MatchString(target.Unit) || units[target.Unit] {
			return errors.New("invalid or duplicate workload unit")
		}
		id, err := spiffeid.FromString(target.Identity)
		if err != nil || len(target.Identity) > 2048 || id.String() != target.Identity || id.TrustDomain().String() != c.TrustDomain || id.Path() == "" {
			return errors.New("workload identity must use the current trust domain")
		}
		if !loopbackAddress(target.Address) || addresses[target.Address] {
			return errors.New("workload addresses must be distinct loopback IPs and ports")
		}
		switch target.Source {
		case sourceGhostunnel, sourceCaddy, sourceEnvoy:
		default:
			return errors.New("invalid workload source")
		}
		units[target.Unit] = true
		addresses[target.Address] = true
	}
	return nil
}
func loopbackAddress(address string) bool {
	host, port, err := net.SplitHostPort(address)
	return err == nil && net.ParseIP(host) != nil && net.ParseIP(host).IsLoopback() && validPort(port)
}

type canaryResult struct {
	metadata canaryMetadata
	err      error
}
type holderObservation struct {
	before, after, validUntil time.Time
	fingerprint               string
	dormant                   bool
	err                       error
}

// systemctl show reads state only. It does not activate a service or its socket.
func (e *exporter) workloadActivity(ctx context.Context) (map[string]string, error) {
	args := []string{"show", "--no-pager", "--property=Id,ActiveState", "--"}
	for _, target := range e.config.Workloads {
		args = append(args, target.Unit)
	}
	op, stop := context.WithTimeout(ctx, operationTimeout)
	defer stop()
	raw, err := e.command(op, e.config.SystemctlBinary, args...)
	if err != nil {
		return nil, err
	}
	return parseWorkloadActivity(raw, e.config.Workloads)
}
func parseWorkloadActivity(raw []byte, targets []WorkloadTarget) (map[string]string, error) {
	if len(raw) > maxAdminBytes {
		return nil, errors.New("workload_unit_metadata")
	}
	expected := map[string]bool{}
	for _, t := range targets {
		expected[t.Unit] = true
	}
	result := map[string]string{}
	var id, state string
	commit := func() bool {
		if id == "" && state == "" {
			return true
		}
		if !expected[id] || state == "" || result[id] != "" {
			return false
		}
		result[id] = state
		id = ""
		state = ""
		return true
	}
	for _, line := range strings.Split(string(raw), "\n") {
		if line == "" {
			if !commit() {
				return nil, errors.New("workload_unit_metadata")
			}
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			return nil, errors.New("workload_unit_metadata")
		}
		switch key {
		case "Id":
			if id != "" {
				return nil, errors.New("workload_unit_metadata")
			}
			id = value
		case "ActiveState":
			if state != "" {
				return nil, errors.New("workload_unit_metadata")
			}
			state = value
		default:
			return nil, errors.New("workload_unit_metadata")
		}
	}
	if !commit() || len(result) != len(targets) {
		return nil, errors.New("workload_unit_metadata")
	}
	return result, nil
}

func (e *exporter) collectWorkloads(ctx context.Context, ready <-chan struct{}, canary *canaryResult) outcome {
	o := outcome{name: "workloads"}
	states, err := e.workloadActivity(ctx)
	if err != nil {
		for _, target := range e.config.Workloads {
			e.recordHolder(target, holderObservation{err: err})
		}
		o.err = err
		return o
	}
	type job struct {
		target WorkloadTarget
		state  string
	}
	jobs := make(chan job, len(e.config.Workloads))
	results := make(chan holderObservation, len(e.config.Workloads))
	for _, target := range e.config.Workloads {
		jobs <- job{target, states[target.Unit]}
	}
	close(jobs)
	workers := min(workloadParallelism, len(e.config.Workloads))
	for i := 0; i < workers; i++ {
		go func() {
			for job := range jobs {
				var observation holderObservation
				switch job.state {
				case "inactive":
					observation.dormant = true
				case "active":
					if job.target.Source == sourceEnvoy {
						observation = observeHolder(ctx, job.target, canaryMetadata{})
					} else {
						select {
						case <-ctx.Done():
							observation.err = ctx.Err()
						case <-ready:
							if canary.err != nil {
								observation.err = errors.New("workload_observer_unavailable")
							} else {
								observation = observeHolder(ctx, job.target, canary.metadata)
							}
						}
					}
				default:
					observation.err = errors.New("workload_unit_not_active")
				}
				if observation.err == nil && !observation.dormant && ctx.Err() != nil {
					observation.err = ctx.Err()
				}
				observation.err = e.recordHolder(job.target, observation)
				results <- observation
			}
		}()
	}
	for range e.config.Workloads {
		observation := <-results
		if observation.err != nil {
			o.err = observation.err
		}
		if !observation.dormant && observation.err == nil {
			o.validUntil = earlier(o.validUntil, observation.validUntil)
		}
	}
	return o
}

func observeHolder(parent context.Context, target WorkloadTarget, observer canaryMetadata) holderObservation {
	o := holderObservation{}
	if !loopbackAddress(target.Address) {
		o.err = errors.New("workload_address")
		return o
	}
	ctx, cancel := context.WithTimeout(parent, operationTimeout)
	defer cancel()
	transport := &http.Transport{Proxy: nil, DisableKeepAlives: true, MaxResponseHeaderBytes: 16 << 10, DialContext: (&net.Dialer{}).DialContext, TLSHandshakeTimeout: operationTimeout, ResponseHeaderTimeout: operationTimeout}
	defer transport.CloseIdleConnections()
	scheme, path, wantStatus := "https", "/", http.StatusNoContent
	switch target.Source {
	case sourceGhostunnel:
		path = "/_metrics/prometheus"
		wantStatus = http.StatusOK
	case sourceCaddy:
	case sourceEnvoy:
		scheme = "http"
		path = "/certs"
		wantStatus = http.StatusOK
	default:
		o.err = errors.New("workload_source")
		return o
	}
	chainExpiry := make(chan time.Time, 1)
	if target.Source != sourceEnvoy {
		if observer.SVID == nil || observer.SVID.PrivateKey == nil || observer.Bundle == nil || observer.Cert == nil || !certCurrent(observer.Cert, time.Now()) {
			o.err = errors.New("workload_observer_unavailable")
			return o
		}
		expected, err := spiffeid.FromString(target.Identity)
		if err != nil {
			o.err = errors.New("workload_identity")
			return o
		}
		authorize := tlsconfig.AuthorizeID(expected)
		transport.TLSClientConfig = tlsconfig.MTLSClientConfig(observer.SVID, observer.Bundle, func(id spiffeid.ID, chains [][]*x509.Certificate) error {
			if err := authorize(id, chains); err != nil {
				return err
			}
			if len(chains) == 0 || len(chains[0]) == 0 {
				return errors.New("workload_chain")
			}
			var validUntil time.Time
			for _, cert := range chains[0] {
				validUntil = earlier(validUntil, cert.NotAfter)
			}
			chainExpiry <- validUntil
			return nil
		})
		transport.TLSClientConfig.MinVersion = tls.VersionTLS13
		o.validUntil = observer.Cert.NotAfter
	}
	client := &http.Client{Transport: transport, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, scheme+"://"+target.Address+path, nil)
	if err != nil {
		o.err = errors.New("workload_request")
		return o
	}
	response, err := client.Do(request)
	if err != nil {
		if ctx.Err() != nil {
			o.err = ctx.Err()
		} else {
			o.err = errors.New("workload_request")
		}
		return o
	}
	defer response.Body.Close()
	if response.StatusCode != wantStatus {
		o.err = errors.New("workload_http_status")
		return o
	}
	raw, err := io.ReadAll(io.LimitReader(response.Body, maxHolderBodyBytes+1))
	if err != nil || len(raw) > maxHolderBodyBytes {
		if ctx.Err() != nil {
			o.err = ctx.Err()
		} else {
			o.err = errors.New("workload_body")
		}
		return o
	}
	if target.Source == sourceEnvoy {
		return parseEnvoyCertificates(raw, target.Identity, time.Now())
	}
	select {
	case validUntil := <-chainExpiry:
		o.validUntil = earlier(o.validUntil, validUntil)
	default:
		o.err = errors.New("workload_chain")
		return o
	}
	if response.TLS == nil || len(response.TLS.PeerCertificates) == 0 {
		o.err = errors.New("workload_chain")
		return o
	}
	leaf := response.TLS.PeerCertificates[0]
	o.before = leaf.NotBefore
	o.after = leaf.NotAfter
	o.fingerprint = fingerprint(leaf)
	if !certCurrent(leaf, time.Now()) || !time.Now().Before(o.validUntil) {
		o.err = errors.New("workload_expired")
	}
	return o
}

type envoySAN struct {
	URI string `json:"uri"`
	DNS string `json:"dns"`
	IP  string `json:"ip_address"`
}
type envoyCertificate struct {
	Serial string     `json:"serial_number"`
	SANs   []envoySAN `json:"subject_alt_names"`
	Before string     `json:"valid_from"`
	After  string     `json:"expiration_time"`
}

func parseEnvoyCertificates(raw []byte, identity string, now time.Time) holderObservation {
	failure := holderObservation{err: errors.New("workload_envoy_metadata")}
	var envelope struct {
		Certificates []struct {
			Chain []envoyCertificate `json:"cert_chain"`
		} `json:"certificates"`
	}
	if len(raw) > maxHolderBodyBytes || json.Unmarshal(raw, &envelope) != nil {
		return failure
	}
	var selected holderObservation
	for _, context := range envelope.Certificates {
		for _, cert := range context.Chain {
			uriCount := 0
			uri := ""
			var sans []string
			if len(cert.SANs) > 64 {
				return failure
			}
			for _, san := range cert.SANs {
				if san.URI != "" {
					uriCount++
					uri = san.URI
					sans = append(sans, "uri:"+san.URI)
				}
				if san.DNS != "" {
					sans = append(sans, "dns:"+san.DNS)
				}
				if san.IP != "" {
					sans = append(sans, "ip:"+san.IP)
				}
			}
			if uriCount != 1 || uri != identity {
				continue
			}
			before, err := time.Parse(time.RFC3339Nano, cert.Before)
			if err != nil {
				return failure
			}
			after, err := time.Parse(time.RFC3339Nano, cert.After)
			if err != nil || cert.Serial == "" || len(cert.Serial) > 256 || !after.After(before) {
				return failure
			}
			if now.Before(before) || !now.Before(after) {
				continue
			}
			sort.Strings(sans)
			normalized, _ := json.Marshal([]any{cert.Serial, sans, before.UTC().Format(time.RFC3339Nano), after.UTC().Format(time.RFC3339Nano)})
			hash := sha256.Sum256(normalized)
			digest := hex.EncodeToString(hash[:])
			if selected.fingerprint != "" && selected.fingerprint != digest {
				return holderObservation{err: errors.New("workload_envoy_ambiguous")}
			}
			selected = holderObservation{before: before, after: after, validUntil: after, fingerprint: digest}
		}
	}
	if selected.fingerprint == "" {
		return failure
	}
	return selected
}

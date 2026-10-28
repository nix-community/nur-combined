package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"net"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"syscall"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
)

const maxConfigBytes = 256 << 10

var nodePattern = regexp.MustCompile(`^[a-z0-9](?:[a-z0-9.-]{0,61}[a-z0-9])?$`)

type Config struct {
	Node              string           `json:"node"`
	TrustDomain       string           `json:"trust_domain"`
	ListenAddress     string           `json:"listen_address"`
	BundlePath        string           `json:"bundle_path"`
	ServerAddress     string           `json:"server_address"`
	WorkloadSocket    string           `json:"workload_socket"`
	ServerAdminSocket string           `json:"server_admin_socket,omitempty"`
	SPIREServerBinary string           `json:"spire_server_binary,omitempty"`
	Nodes             []string         `json:"nodes,omitempty"`
	SystemctlBinary   string           `json:"systemctl_binary,omitempty"`
	Workloads         []WorkloadTarget `json:"workloads,omitempty"`
}

func readConfig(path string) (Config, error) {
	c := Config{ListenAddress: "127.0.0.1:18494", BundlePath: "/var/lib/realm-spire/trust-bundle.pem", ServerAddress: "eihort.nyaw.xyz:8081", WorkloadSocket: "/run/spire/agent/public/api.sock"}
	raw, err := readPublicFile(path, maxConfigBytes)
	if err != nil {
		return c, errors.New("cannot read configuration")
	}
	d := json.NewDecoder(bytes.NewReader(raw))
	d.DisallowUnknownFields()
	if err := d.Decode(&c); err != nil {
		return c, errors.New("invalid configuration JSON")
	}
	if d.Decode(new(any)) != io.EOF {
		return c, errors.New("unexpected configuration data")
	}
	return c, c.validate()
}

func (c Config) validate() error {
	if !validNode(c.Node) {
		return errors.New("invalid node")
	}
	td, err := spiffeid.TrustDomainFromString(c.TrustDomain)
	if err != nil || td.String() != c.TrustDomain || c.TrustDomain == "" {
		return errors.New("invalid trust_domain")
	}
	host, port, err := net.SplitHostPort(c.ListenAddress)
	if err != nil || net.ParseIP(host) == nil || !net.ParseIP(host).IsLoopback() || !validPort(port) {
		return errors.New("listen_address must use a loopback IP and port")
	}
	host, port, err = net.SplitHostPort(c.ServerAddress)
	if err != nil || host == "" || len(host) > 253 || !validPort(port) {
		return errors.New("invalid server_address")
	}
	for _, p := range []string{c.BundlePath, c.WorkloadSocket} {
		if !cleanAbsolute(p) {
			return errors.New("file and socket paths must be absolute")
		}
	}
	admin := c.ServerAdminSocket != "" || c.SPIREServerBinary != ""
	if admin && (c.Node != "eihort" || !cleanAbsolute(c.ServerAdminSocket) || !cleanAbsolute(c.SPIREServerBinary) || filepath.Base(c.SPIREServerBinary) != "spire-server") {
		return errors.New("admin collection requires Eihort and absolute socket and spire-server paths")
	}
	if len(c.Nodes) > 128 {
		return errors.New("too many nodes")
	}
	seen := map[string]bool{}
	for _, node := range c.Nodes {
		if !validNode(node) || seen[node] {
			return errors.New("invalid or duplicate cohort node")
		}
		seen[node] = true
	}
	if len(c.Nodes) > 0 && !admin {
		return errors.New("nodes require admin collection")
	}
	if admin && len(c.Nodes) == 0 {
		return errors.New("admin collection requires explicit nodes")
	}
	return c.validateWorkloads()
}
func validNode(node string) bool {
	if !nodePattern.MatchString(node) {
		return false
	}
	for _, label := range strings.Split(node, ".") {
		if !nodePattern.MatchString(label) {
			return false
		}
	}
	return true
}

func cleanAbsolute(p string) bool { return filepath.IsAbs(p) && filepath.Clean(p) == p && p != "/" }
func validPort(p string) bool     { n, e := strconv.Atoi(p); return e == nil && n > 0 && n <= 65535 }
func (c Config) canaryID() string {
	return "spiffe://" + c.TrustDomain + "/observer/identity/" + c.Node
}
func (c Config) agentID(node string) string {
	return "spiffe://" + c.TrustDomain + "/spire/agent/http_fqdn/" + node
}
func (c Config) aliasID(node string) string { return "spiffe://" + c.TrustDomain + "/agent/" + node }

// Read only bounded regular files. Do not open a FIFO and wait for a writer.
func readPublicFile(path string, limit int64) ([]byte, error) {
	f, err := openNonblock(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()
	info, err := f.Stat()
	if err != nil {
		return nil, err
	}
	if !info.Mode().IsRegular() || info.Size() > limit {
		return nil, errors.New("invalid public file")
	}
	raw, err := io.ReadAll(io.LimitReader(f, limit+1))
	if err != nil {
		return nil, err
	}
	if int64(len(raw)) > limit {
		return nil, errors.New("public file exceeds limit")
	}
	return raw, nil
}

// The package targets Linux, as do the SPIRE socket paths.
func openNonblock(path string) (*os.File, error) {
	return os.OpenFile(path, os.O_RDONLY|syscall.O_NONBLOCK, 0)
}

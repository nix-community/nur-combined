package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/netip"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

type route struct {
	Prefix string `json:"prefix"`
	Port   uint16 `json:"port"`
	Socket string `json:"socket"`
}

type workload struct {
	Name            string              `json:"name"`
	Unit            string              `json:"unit,omitempty"`
	User            string              `json:"user"`
	Group           string              `json:"group"`
	WorkerUser      string              `json:"workerUser"`
	Socket          string              `json:"socket"`
	InternetSocket  string              `json:"internetSocket,omitempty"`
	InternetPorts   []uint16            `json:"internetPorts"`
	DNSUpstream     string              `json:"dnsUpstream"`
	DNSHosts        map[string][]string `json:"dnsHosts"`
	Routes          []route             `json:"routes"`
	TCPPort         uint16              `json:"tcpPort"`
	DNSBase         uint16              `json:"dnsBase"`
	MaxConnections  int                 `json:"maxConnections"`
	WorkerMemoryMiB int                 `json:"workerMemoryMiB"`
	WorkerTasks     int                 `json:"workerTasks"`
	WorkerCPUQuota  int                 `json:"workerCPUQuota"`
}

type configuration struct {
	NamespaceTool string     `json:"namespaceTool"`
	CABundle      string     `json:"caBundle"`
	NetworkTool   string     `json:"networkTool"`
	Workloads     []workload `json:"workloads"`
}

func decodeConfig(r io.Reader) (configuration, error) {
	var c configuration
	d := json.NewDecoder(io.LimitReader(r, 1<<20))
	d.DisallowUnknownFields()
	if err := d.Decode(&c); err != nil {
		return c, err
	}
	var extra interface{}
	if err := d.Decode(&extra); err != io.EOF {
		return c, errors.New("configuration must contain one JSON object")
	}
	if c.NamespaceTool == "" {
		c.NamespaceTool = "/run/current-system/sw/bin/nsenter"
	}
	if c.NetworkTool == "" {
		c.NetworkTool = "/run/current-system/sw/bin/ip"
	}
	if !filepath.IsAbs(c.NetworkTool) {
		return c, errors.New("networkTool must be absolute")
	}
	if !filepath.IsAbs(c.NamespaceTool) {
		return c, errors.New("namespaceTool must be absolute")
	}
	if c.CABundle == "" {
		c.CABundle = "/etc/ssl/certs/ca-certificates.crt"
	}
	if !filepath.IsAbs(c.CABundle) {
		return c, errors.New("caBundle must be absolute")
	}
	seen := map[string]bool{}
	sockets := map[string]bool{}
	directories := map[string]bool{}
	for i := range c.Workloads {
		w := &c.Workloads[i]
		if err := w.validate(); err != nil {
			return c, fmt.Errorf("workload %q: %w", w.Name, err)
		}
		if seen[w.Name] || sockets[w.Socket] || directories[filepath.Dir(w.Socket)] {
			return c, errors.New("duplicate workload or control socket")
		}
		seen[w.Name] = true
		sockets[w.Socket] = true
		directories[filepath.Dir(w.Socket)] = true
	}
	return c, nil
}

func loadConfig(path string) (configuration, error) {
	f, e := os.Open(path)
	if e != nil {
		return configuration{}, e
	}
	defer f.Close()
	return decodeConfig(f)
}

func (w *workload) validate() error {
	if !regexp.MustCompile(`^[a-z][a-z0-9-]{0,30}$`).MatchString(w.Name) {
		return errors.New("invalid name")
	}
	if w.Unit != "" && !regexp.MustCompile(`^[a-zA-Z0-9_:@.\\-]+\.service$`).MatchString(w.Unit) {
		return errors.New("unit must be a concrete system service name")
	}
	if w.User == "" || w.User == "root" || w.WorkerUser == "" || w.WorkerUser == "root" || w.User == w.WorkerUser || w.Group == "" || w.Group == "root" {
		return errors.New("distinct unprivileged application and worker accounts are required")
	}
	if !filepath.IsAbs(w.Socket) {
		return errors.New("socket must be absolute")
	}
	if w.TCPPort == 0 {
		w.TCPPort = 15001
	}
	if w.DNSBase == 0 {
		w.DNSBase = 15053
	}
	if w.DNSBase > 65528 || (w.TCPPort >= w.DNSBase && w.TCPPort < w.DNSBase+8) || w.TCPPort == 53 || (w.DNSBase <= 53 && w.DNSBase+7 >= 53) {
		return errors.New("invalid or overlapping listener ports")
	}
	if w.MaxConnections == 0 {
		w.MaxConnections = 256
	}
	if w.MaxConnections < 1 || w.MaxConnections > 4096 {
		return errors.New("maxConnections must be 1..4096")
	}
	if w.WorkerMemoryMiB == 0 {
		w.WorkerMemoryMiB = 128
	}
	if w.WorkerTasks == 0 {
		w.WorkerTasks = 64
	}
	if w.WorkerCPUQuota == 0 {
		w.WorkerCPUQuota = 100
	}
	if w.WorkerMemoryMiB < 32 || w.WorkerMemoryMiB > 4096 || w.WorkerTasks < 16 || w.WorkerTasks > 512 || w.WorkerCPUQuota < 1 || w.WorkerCPUQuota > 800 {
		return errors.New("invalid worker resource budget")
	}
	if w.InternetSocket != "" && !filepath.IsAbs(w.InternetSocket) {
		return errors.New("internetSocket must be absolute")
	}
	if w.DNSUpstream == "" {
		w.DNSUpstream = "https://cloudflare-dns.com/dns-query"
	}
	u, e := url.Parse(w.DNSUpstream)
	if e != nil || u.Scheme != "https" || u.Hostname() == "" || u.User != nil {
		return errors.New("dnsUpstream must be an HTTPS URL without credentials")
	}
	for _, p := range w.InternetPorts {
		if p == 0 {
			return errors.New("invalid Internet port")
		}
	}
	for name, addresses := range w.DNSHosts {
		if name == "" || strings.ContainsAny(name, " \n\t/") || len(addresses) == 0 {
			return errors.New("invalid DNS host")
		}
		for _, s := range addresses {
			if _, e := netip.ParseAddr(s); e != nil {
				return fmt.Errorf("DNS address: %w", e)
			}
		}
	}
	for _, r := range w.Routes {
		if _, e := netip.ParsePrefix(r.Prefix); e != nil {
			return e
		}
		if r.Port == 0 || !filepath.IsAbs(r.Socket) {
			return errors.New("routes need a port and absolute socket")
		}
	}
	return nil
}

var forbiddenPrefixes = func() []netip.Prefix {
	var out []netip.Prefix
	for _, p := range []string{"0.0.0.0/8", "10.0.0.0/8", "100.64.0.0/10", "127.0.0.0/8", "169.254.0.0/16", "172.16.0.0/12", "192.0.0.0/24", "192.168.0.0/16", "198.18.0.0/15", "224.0.0.0/4", "240.0.0.0/4", "::/128", "::1/128", "::ffff:0:0/96", "200::/7", "fc00::/7", "fe80::/10", "fec0::/10", "ff00::/8"} {
		out = append(out, netip.MustParsePrefix(p))
	}
	return out
}()

func (w workload) target(a netip.AddrPort) (string, error) {
	selected := ""
	bits := -1
	for _, r := range w.Routes {
		p := netip.MustParsePrefix(r.Prefix)
		if r.Port == a.Port() && p.Contains(a.Addr()) && p.Bits() > bits {
			selected = r.Socket
			bits = p.Bits()
		}
	}
	if selected != "" {
		return selected, nil
	}
	for _, p := range forbiddenPrefixes {
		if p.Contains(a.Addr()) {
			return "", errors.New("undeclared private or reserved destination")
		}
	}
	for _, p := range w.InternetPorts {
		if p == a.Port() && w.InternetSocket != "" {
			return w.InternetSocket, nil
		}
	}
	return "", errors.New("destination port is not authorized")
}

package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"slices"
	"time"
)

type namespaceLink struct {
	Name      string   `json:"ifname"`
	Flags     []string `json:"flags"`
	Immutable bool     `json:"netns-immutable"`
	Info      struct {
		Kind string `json:"info_kind"`
		Data struct {
			Local  string `json:"local"`
			Remote string `json:"remote"`
			Link   int    `json:"link"`
		} `json:"info_data"`
	} `json:"linkinfo"`
}

var fallbackTunnelKinds = map[string]string{
	"ip6tnl0": "ip6tnl", "gre0": "gre", "gretap0": "gretap", "erspan0": "erspan",
}

// Loading ip6_tunnel creates this DOWN fallback in every network namespace.
// It is inert only without endpoints, addresses or routes. Applications and
// forwarding workers have no CAP_NET_ADMIN to bring it up or configure it.
func (l namespaceLink) inertFallback() bool {
	unspecified := func(s string) bool { return s == "" || s == "any" || s == "::" }
	return fallbackTunnelKinds[l.Name] != "" && l.Info.Kind == fallbackTunnelKinds[l.Name] && l.Immutable &&
		!slices.Contains(l.Flags, "UP") && l.Info.Data.Link == 0 &&
		unspecified(l.Info.Data.Local) && unspecified(l.Info.Data.Remote)
}

// Libraries using AI_ADDRCONFIG, including CacheableLookup with Node's socket
// options, ignore all DNS answers if the namespace has only loopback. A dummy
// interface advertises both address families without providing an external
// link or default route. No physical/veth/TUN interface is accepted here.
func (c *controller) setupNetwork(ctx context.Context, ns *os.File) error {
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	ip := func(args ...string) ([]byte, error) {
		command := exec.CommandContext(ctx, c.config.NamespaceTool, append([]string{"--net=/proc/self/fd/3", "--", c.config.NetworkTool}, args...)...)
		command.ExtraFiles = []*os.File{ns}
		command.Dir = "/"
		command.Env = []string{"PATH=/run/current-system/sw/bin"}
		out, e := command.CombinedOutput()
		if e != nil {
			return nil, fmt.Errorf("private namespace ip %v: %w: %s", args, e, out)
		}
		return out, nil
	}
	raw, e := ip("-d", "-j", "link", "show")
	if e != nil {
		return e
	}
	var links []namespaceLink
	if e = json.Unmarshal(raw, &links); e != nil {
		return e
	}
	exists := false
	fallbacks := map[string]bool{}
	for _, l := range links {
		if l.Name == "lo" {
			continue
		}
		if l.inertFallback() {
			raw, e := ip("-j", "address", "show", "dev", l.Name)
			if e != nil {
				return e
			}
			var addresses []struct {
				Addresses []json.RawMessage `json:"addr_info"`
			}
			if e := json.Unmarshal(raw, &addresses); e != nil {
				return e
			}
			if len(addresses) != 1 || len(addresses[0].Addresses) != 0 {
				return fmt.Errorf("fallback tunnel %s has addresses", l.Name)
			}
			fallbacks[l.Name] = true
			continue
		}
		if l.Name != "realm0" || l.Info.Kind != "dummy" {
			return fmt.Errorf("refusing namespace with external-capable interface %s", l.Name)
		}
		exists = true
	}
	// Also reject configured default routes, even when they point at a dummy.
	for _, family := range []string{"-4", "-6"} {
		b, e := ip(family, "-j", "route", "show", "table", "all")
		if e != nil {
			return e
		}
		var routes []struct {
			Destination string `json:"dst"`
			Device      string `json:"dev"`
		}
		if e = json.Unmarshal(b, &routes); e != nil {
			return e
		}
		for _, r := range routes {
			if fallbacks[r.Device] {
				return fmt.Errorf("fallback tunnel %s has routes", r.Device)
			}
			if r.Destination == "default" {
				return errors.New("private namespace must not have a default route")
			}
		}
	}
	if !exists {
		if _, e = ip("link", "add", "realm0", "type", "dummy"); e != nil {
			return e
		}
	}
	for _, args := range [][]string{{"-4", "address", "replace", "192.0.2.254/32", "dev", "realm0"}, {"-6", "address", "replace", "2001:db8::ffff/128", "dev", "realm0", "nodad"}, {"link", "set", "realm0", "up"}} {
		if _, e = ip(args...); e != nil {
			return e
		}
	}
	return nil
}

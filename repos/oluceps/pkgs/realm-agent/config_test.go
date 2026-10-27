package main

import (
	"net/netip"
	"strings"
	"testing"

	"github.com/miekg/dns"
)

func TestDestinationPolicy(t *testing.T) {
	w := workload{InternetSocket: "/internet.sock", InternetPorts: []uint16{80, 443}, Routes: []route{{"fdcc::/16", 443, "/broad.sock"}, {"fdcc::3/128", 443, "/service.sock"}}}
	for _, tc := range []struct {
		address, want string
		deny          bool
	}{
		{"1.1.1.1:443", "/internet.sock", false}, {"1.1.1.1:22", "", true},
		{"127.0.0.1:443", "", true}, {"169.254.169.254:80", "", true}, {"192.168.0.20:443", "", true},
		{"[fdcc::3]:443", "/service.sock", false}, {"[fdcc::4]:443", "/broad.sock", false}, {"[fdcc::3]:22", "", true},
		{"[fe80::1]:443", "", true}, {"[2001:4860:4860::8888]:443", "/internet.sock", false},
	} {
		t.Run(tc.address, func(t *testing.T) {
			got, e := w.target(netip.MustParseAddrPort(tc.address))
			if (e != nil) != tc.deny || got != tc.want {
				t.Fatalf("got %q, %v", got, e)
			}
		})
	}
}

func TestConfigurationSafety(t *testing.T) {
	good := `{"workloads":[{"name":"fixture","user":"app","workerUser":"adapter","group":"app","socket":"/run/fixture/control.sock"}]}`
	if _, e := decodeConfig(strings.NewReader(good)); e != nil {
		t.Fatal(e)
	}
	for _, bad := range []string{strings.Replace(good, `"user":"app"`, `"user":"root"`, 1), strings.Replace(good, `"workerUser":"adapter"`, `"workerUser":"app"`, 1), strings.Replace(good, `"socket":"/run/fixture/control.sock"`, `"socket":"relative"`, 1), strings.Replace(good, `"name":"fixture"`, `"typo":true,"name":"fixture"`, 1), good + ` {}`} {
		if _, e := decodeConfig(strings.NewReader(bad)); e == nil {
			t.Fatalf("accepted unsafe config %s", bad)
		}
	}
}

func TestDNSAliasesAndNoInternet(t *testing.T) {
	w := workload{DNSHosts: map[string][]string{"s3.nyaw.xyz": {"127.0.0.1"}, "dual.test": {"192.0.2.1", "2001:db8::1"}}}
	r := newResolver(w)
	for _, tc := range []struct {
		name         string
		kind         uint16
		count, rcode int
	}{
		{"S3.NYAW.XYZ.", dns.TypeA, 1, 0}, {"s3.nyaw.xyz.", dns.TypeAAAA, 0, 0}, {"dual.test.", dns.TypeAAAA, 1, 0}, {"unknown.test.", dns.TypeA, 0, dns.RcodeRefused},
	} {
		q := new(dns.Msg)
		q.SetQuestion(tc.name, tc.kind)
		a := r.answer(q)
		if a.Rcode != tc.rcode || len(a.Answer) != tc.count || a.Id != q.Id {
			t.Fatalf("%s: %+v", tc.name, a)
		}
	}
}

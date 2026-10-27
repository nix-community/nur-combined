package main

import "testing"

func TestFallbackTunnelMustBeUnconfiguredAndDown(t *testing.T) {
	var fallback namespaceLink
	fallback.Name = "ip6tnl0"
	fallback.Flags = []string{"NOARP"}
	fallback.Info.Kind = "ip6tnl"
	fallback.Immutable = true
	fallback.Info.Data.Local = "any"
	fallback.Info.Data.Remote = "any"
	if !fallback.inertFallback() {
		t.Fatal("kernel fallback was rejected")
	}
	for _, change := range []func(*namespaceLink){
		func(l *namespaceLink) { l.Immutable = false },
		func(l *namespaceLink) { l.Flags = []string{"UP", "NOARP"} },
		func(l *namespaceLink) { l.Info.Kind = "tun" },
		func(l *namespaceLink) { l.Name = "configured-tunnel" },
		func(l *namespaceLink) { l.Info.Data.Local = "2001:db8::1" },
		func(l *namespaceLink) { l.Info.Data.Remote = "2001:db8::2" },
		func(l *namespaceLink) { l.Info.Data.Link = 4 },
	} {
		configured := fallback
		change(&configured)
		if configured.inertFallback() {
			t.Fatalf("accepted configured link: %+v", configured)
		}
	}
	for name, kind := range fallbackTunnelKinds {
		link := fallback
		link.Name, link.Info.Kind = name, kind
		if !link.inertFallback() {
			t.Fatalf("rejected kernel fallback: %s", name)
		}
	}
}

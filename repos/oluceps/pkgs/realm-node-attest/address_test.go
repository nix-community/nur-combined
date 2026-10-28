package nodeattest

import (
	"context"
	"net"
	"net/netip"
	"os"
	"path/filepath"
	"testing"
)

func TestPinnedAddressPolicySupportsMeshAndRejectsUnsafeDestinations(t *testing.T) {
	for _, text := range []string{"0.0.0.0", "0.0.0.1", "127.0.0.1", "169.254.169.254", "224.0.0.1", "240.0.0.1", "::", "::1", "::ffff:93.184.216.34", "fe80::1", "ff02::1"} {
		if validAddress(netip.MustParseAddr(text)) {
			t.Errorf("unsafe pinned address accepted: %s", text)
		}
	}
	for _, text := range []string{"fdcc::3", "10.9.8.3", "192.168.0.20", fixtureIP} {
		if !validAddress(netip.MustParseAddr(text)) {
			t.Errorf("registry address rejected: %s", text)
		}
	}
}

func TestControlPeerUsesKernelCredentialsThroughConnectionLimit(t *testing.T) {
	path := filepath.Join(t.TempDir(), "peer.sock")
	listener, err := net.Listen("unix", path)
	if err != nil {
		t.Fatal(err)
	}
	limited := limitListener(listener, 1)
	defer limited.Close()
	result := make(chan bool, 1)
	go func() {
		connection, err := limited.Accept()
		if err != nil {
			result <- false
			return
		}
		defer connection.Close()
		result <- rootPeer(connection)
	}()
	connection, err := net.Dial("unix", path)
	if err != nil {
		t.Fatal(err)
	}
	defer connection.Close()
	if got := <-result; got != (os.Geteuid() == 0) {
		t.Fatalf("peer authority %v did not match kernel UID", got)
	}
}

func TestGlobalReservationsAndCancellationRelease(t *testing.T) {
	config := fixtureConfig()
	config.Nodes = map[string]NodePolicy{}
	for _, name := range []string{"first", "second"} {
		config.Nodes[name] = NodePolicy{FQDN: name + ".nyaw.xyz", Addresses: []string{fixtureIP}}
	}
	s, err := NewServer(config)
	if err != nil {
		t.Fatal(err)
	}
	a, err := BeginAgent(AgentConfig{FQDN: "first.nyaw.xyz", TrustDomain: "nyaw.xyz", ControlSocket: "/unused/control.sock"})
	if err != nil {
		t.Fatal(err)
	}
	defer a.Close()
	ctx, cancel := context.WithCancel(context.Background())
	attempt, err := s.Begin(ctx, a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	cancel()
	<-attempt.Context().Done()
	// An explicit close is safe even when the cancellation callback races it.
	attempt.Close()
	replacement, err := s.Begin(context.Background(), a.Payload())
	if err != nil {
		t.Fatal(err)
	}
	replacement.Close()
}

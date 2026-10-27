package main

import (
	"encoding/json"
	"errors"
	"io"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"sync/atomic"
	"testing"
	"time"

	"github.com/miekg/dns"
	"golang.org/x/sys/unix"
)

func TestPeerProcessLiveAndExited(t *testing.T) {
	if os.Getenv("REALM_TEST_PEER") != "" {
		c, e := net.Dial("unix", os.Getenv("REALM_TEST_PEER"))
		if e != nil {
			os.Exit(2)
		}
		c.Write([]byte{1})
		os.Exit(0)
	}
	path := filepath.Join(t.TempDir(), "peer.sock")
	l, e := net.ListenUnix("unix", &net.UnixAddr{Name: path, Net: "unix"})
	if e != nil {
		t.Fatal(e)
	}
	defer l.Close()
	c, e := net.Dial("unix", path)
	if e != nil {
		t.Fatal(e)
	}
	defer c.Close()
	accepted, e := l.AcceptUnix()
	if e != nil {
		t.Fatal(e)
	}
	proc, cred, e := peerProcess(accepted)
	accepted.Close()
	if e != nil {
		t.Fatal(e)
	}
	proc.Close()
	if int(cred.Pid) != os.Getpid() {
		t.Fatalf("wrong peer PID: %v", cred)
	}
	child := exec.Command(os.Args[0], "-test.run=^TestPeerProcessLiveAndExited$")
	child.Env = []string{"REALM_TEST_PEER=" + path}
	if e := child.Start(); e != nil {
		t.Fatal(e)
	}
	exited, e := l.AcceptUnix()
	if e != nil {
		t.Fatal(e)
	}
	defer exited.Close()
	var ready [1]byte
	if _, e := io.ReadFull(exited, ready[:]); e != nil {
		t.Fatal(e)
	}
	if e := child.Wait(); e != nil {
		t.Fatal(e)
	}
	if f, _, e := peerProcess(exited); e == nil {
		f.Close()
		t.Fatal("accepted an exited peer")
	}
}

func TestWorkerConfigSealedAndReadOnly(t *testing.T) {
	w := workload{Name: "fixture", User: "app", Group: "app", WorkerUser: "worker", Socket: "/run/fixture/control.sock"}
	f, e := sealedWorkerConfig(w, "/ca.crt")
	if e != nil {
		t.Fatal(e)
	}
	defer f.Close()
	if _, e := f.Write([]byte("changed")); e == nil {
		t.Fatal("worker can modify config")
	}
	var got workerConfiguration
	if e := json.NewDecoder(f).Decode(&got); e != nil {
		t.Fatal(e)
	}
	if got.Workload.Name != w.Name || got.CABundle != "/ca.crt" {
		t.Fatalf("wrong config: %+v", got)
	}
	if _, e := unix.FcntlInt(f.Fd(), unix.F_GET_SEALS, 0); e != nil {
		t.Fatal(e)
	}
	for _, socket := range []string{"/run/broad.sock", "/proc/self/mem", "/nix/store/socket", "/run/realm-agent/other/socket"} {
		if _, e := workerSocketDirectories(workload{InternetSocket: socket}); e == nil {
			t.Fatalf("exposes broad tree: %s", socket)
		}
	}
	dirs, e := workerSocketDirectories(workload{InternetSocket: "/run/realm/fixture/egress/internet.sock", Routes: []route{{Socket: "/run/realm/fixture/egress/service.sock"}}})
	if e != nil || len(dirs) != 1 {
		t.Fatalf("directory mounts: %v %v", dirs, e)
	}
}

func TestDNSBoundedQueue(t *testing.T) {
	// Deliberately block handlers. Enqueuing excess work must not start extra
	// handlers or grow the queue, even before a DNS message is unpacked.
	s := &udpDNS{queue: make(chan udpQuery, 2), stop: make(chan struct{})}
	c, e := net.ListenUDP("udp4", &net.UDPAddr{IP: net.ParseIP("127.0.0.1")})
	if e != nil {
		t.Fatal(e)
	}
	defer c.Close()
	entered := make(chan struct{}, 2)
	release := make(chan struct{})
	var active, peak atomic.Int32
	answer := func(q *dns.Msg) *dns.Msg {
		n := active.Add(1)
		for old := peak.Load(); n > old && !peak.CompareAndSwap(old, n); old = peak.Load() {
		}
		entered <- struct{}{}
		<-release
		active.Add(-1)
		return new(dns.Msg).SetReply(q)
	}
	for i := 0; i < 2; i++ {
		s.wg.Add(1)
		go s.work(answer)
	}
	q := new(dns.Msg)
	q.SetQuestion("fixture.test.", dns.TypeA)
	wire, _ := q.Pack()
	item := udpQuery{c, c.LocalAddr().(*net.UDPAddr), wire}
	s.queue <- item
	s.queue <- item
	for i := 0; i < 2; i++ {
		select {
		case <-entered:
		case <-time.After(time.Second):
			t.Fatal("worker not ready")
		}
	}
	for i := 0; i < 1000; i++ {
		select {
		case s.queue <- item:
		default:
		}
	}
	if len(s.queue) != 2 || peak.Load() != 2 {
		t.Fatalf("unbounded DNS work: queue %d peak %d", len(s.queue), peak.Load())
	}
	close(s.stop)
	close(release)
	s.wg.Wait()
}

func TestDNSOccupiedListenerAndRecovery(t *testing.T) {
	occupied, e := net.ListenUDP("udp4", &net.UDPAddr{IP: net.ParseIP("127.0.0.1")})
	if e != nil {
		t.Fatal(e)
	}
	defer occupied.Close()
	port := uint16(occupied.LocalAddr().(*net.UDPAddr).Port)
	if _, e := startDNS(newResolver(workload{}), port); !errors.Is(e, unix.EADDRINUSE) {
		t.Fatalf("expected occupied port failure: %v", e)
	}
	// A corrupt workload state is handled within its reconciliation goroutine;
	// it cannot prevent another independent controller from being inspected.
	bad := controller{workload: workload{Name: "bad", Socket: filepath.Join(t.TempDir(), "control.sock")}}
	if e := os.WriteFile(bad.statePath(), []byte("not json"), 0600); e != nil {
		t.Fatal(e)
	}
	if e := bad.recover(t.Context()); e == nil {
		t.Fatal("corrupt state should fail recovery")
	}
	good := controller{workload: workload{Name: "good", Socket: filepath.Join(t.TempDir(), "control.sock")}}
	if e := good.recover(t.Context()); e != nil {
		t.Fatal(e)
	}
}

func TestEmptyStartupGapRetainsCapture(t *testing.T) {
	dir := t.TempDir()
	events := filepath.Join(dir, "cgroup.events")
	if e := os.WriteFile(events, []byte("populated 0\n"), 0600); e != nil {
		t.Fatal(e)
	}
	cg, e := os.Open(dir)
	if e != nil {
		t.Fatal(e)
	}
	defer cg.Close()
	i := instance{cgroup: cg}
	now := time.Now()
	if i.expiredEmpty(now) || i.expiredEmpty(now.Add(2*time.Second)) {
		t.Fatal("released between gate and ExecStart")
	}
	if e := os.WriteFile(events, []byte("populated 1\n"), 0600); e != nil {
		t.Fatal(e)
	}
	if i.expiredEmpty(now.Add(31 * time.Second)) {
		t.Fatal("released populated application")
	}
	if e := os.WriteFile(events, []byte("populated 0\n"), 0600); e != nil {
		t.Fatal(e)
	}
	if i.expiredEmpty(now.Add(time.Minute)) {
		t.Fatal("empty grace did not reset")
	}
	if !i.expiredEmpty(now.Add(91 * time.Second)) {
		t.Fatal("stopped workload not released")
	}
}

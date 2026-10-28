//go:build linux

package nodeattest

import (
	"context"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"testing"
	"time"
)

func TestResponderActivatedMetricsLifecycle(t *testing.T) {
	if os.Getenv("REALM_METRICS_TEST_CHILD") == "1" {
		var cfg ResponderConfig
		if json.Unmarshal([]byte(os.Getenv("REALM_METRICS_TEST_CONFIG")), &cfg) != nil {
			t.Fatal("invalid fixture configuration")
		}
		t.Setenv("LISTEN_PID", strconv.Itoa(os.Getpid()))
		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()
		go func() { _, _ = io.Copy(io.Discard, os.Stdin); cancel() }()
		if RunResponder(ctx, cfg) != nil {
			t.Fatal("activated responder failed")
		}
		return
	}
	control, err := net.ListenUnix("unix", &net.UnixAddr{Name: filepath.Join(t.TempDir(), "control.sock"), Net: "unix"})
	if err != nil {
		t.Fatal(err)
	}
	defer control.Close()
	public, err := net.ListenTCP("tcp4", &net.TCPAddr{IP: net.IPv4(127, 0, 0, 1)})
	if err != nil {
		t.Fatal(err)
	}
	defer public.Close()
	controlFile, err := control.File()
	if err != nil {
		t.Fatal(err)
	}
	defer controlFile.Close()
	publicFile, err := public.File()
	if err != nil {
		t.Fatal(err)
	}
	defer publicFile.Close()
	metrics, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	metricsAddress := metrics.Addr().String()
	_ = metrics.Close()
	cfg := ResponderConfig{FQDN: fixtureFQDN, Port: public.Addr().(*net.TCPAddr).Port, ControlSocket: control.Addr().String(), MetricsAddress: metricsAddress}
	raw, _ := json.Marshal(cfg)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	command := exec.CommandContext(ctx, os.Args[0], "-test.run=^TestResponderActivatedMetricsLifecycle$")
	command.Env = append(os.Environ(), "REALM_METRICS_TEST_CHILD=1", "REALM_METRICS_TEST_CONFIG="+string(raw), "LISTEN_FDS=2", "LISTEN_FDNAMES=control:http4")
	command.ExtraFiles = []*os.File{controlFile, publicFile}
	input, err := command.StdinPipe()
	if err != nil {
		t.Fatal(err)
	}
	command.Stdout, command.Stderr = io.Discard, io.Discard
	if err := command.Start(); err != nil {
		t.Fatal(err)
	}
	defer func() {
		_ = input.Close()
		if command.ProcessState == nil {
			_ = command.Process.Kill()
			_ = command.Wait()
		}
	}()
	client := &http.Client{Timeout: time.Second, Transport: &http.Transport{Proxy: nil, DisableKeepAlives: true}}
	ready := false
	for range 100 {
		response, err := client.Get("http://" + metricsAddress + "/metrics")
		if err == nil {
			_, _ = io.Copy(io.Discard, response.Body)
			_ = response.Body.Close()
			ready = response.StatusCode == http.StatusOK
			break
		}
		time.Sleep(10 * time.Millisecond)
	}
	if !ready {
		t.Fatal("activated responder did not expose metrics")
	}
	request, _ := http.NewRequest(http.MethodGet, "http://"+public.Addr().String()+"/metrics", nil)
	request.Host = net.JoinHostPort(fixtureFQDN, strconv.Itoa(cfg.Port))
	response, err := client.Do(request)
	if err != nil {
		t.Fatal("activated proof listener failed")
	}
	_ = response.Body.Close()
	if response.StatusCode != http.StatusNotFound {
		t.Fatal("proof socket exposed metrics")
	}
	_ = input.Close()
	if err := command.Wait(); err != nil {
		t.Fatal("activated responder did not stop cleanly")
	}
	assertPortReleased(t, metricsAddress)
}

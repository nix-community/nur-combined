package main

import (
	"encoding/json"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"testing"
)

// echoListener answers every connection with one fixed line.
func echoListener(t *testing.T, network, address string) net.Listener {
	t.Helper()
	listener, err := net.Listen(network, address)
	if err != nil {
		t.Fatalf("listen %s %s: %v", network, address, err)
	}
	t.Cleanup(func() { listener.Close() })
	go func() {
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			go func() {
				defer conn.Close()
				conn.Write([]byte("mesh\n"))
			}()
		}
	}()
	return listener
}

func readLine(t *testing.T, conn net.Conn) string {
	t.Helper()
	buffer := make([]byte, 64)
	size, err := conn.Read(buffer)
	if err != nil {
		t.Fatalf("read: %v", err)
	}
	return string(buffer[:size])
}

func TestStartContainerRoutesBridgesLoopbackAndIngress(t *testing.T) {
	directory := t.TempDir()
	egressPath := filepath.Join(directory, "egress.sock")
	echoListener(t, "unix", egressPath)
	backend := filepath.Join(directory, "backend.sock")

	// Pick a free port, then let the route bridge bind it.
	free, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatalf("find free port: %v", err)
	}
	port := free.Addr().(*net.TCPAddr).Port
	free.Close()

	routes, err := json.Marshal([]route{{Port: port, Socket: egressPath}})
	if err != nil {
		t.Fatalf("encode routes: %v", err)
	}
	routesFile := filepath.Join(directory, "routes.json")
	if err := os.WriteFile(routesFile, routes, 0o644); err != nil {
		t.Fatalf("write routes: %v", err)
	}

	previousRoutes, previousBackend := routesPath, backendPath
	routesPath, backendPath = routesFile, backend
	t.Cleanup(func() { routesPath, backendPath = previousRoutes, previousBackend })

	ingress := echoListener(t, "tcp", "127.0.0.1:0")
	t.Setenv("REALM_INGRESS_PORT", strconv.Itoa(ingress.Addr().(*net.TCPAddr).Port))

	if err := startContainerRoutes(); err != nil {
		t.Fatalf("start container routes: %v", err)
	}

	t.Run("route adapter reaches the mounted egress socket", func(t *testing.T) {
		conn, err := net.Dial("tcp", net.JoinHostPort("127.0.0.1", strconv.Itoa(port)))
		if err != nil {
			t.Fatalf("dial route: %v", err)
		}
		defer conn.Close()
		if got := readLine(t, conn); got != "mesh\n" {
			t.Fatalf("unexpected payload %q", got)
		}
	})

	t.Run("ingress socket publishes the application port", func(t *testing.T) {
		info, err := os.Stat(backend)
		if err != nil {
			t.Fatalf("stat ingress socket: %v", err)
		}
		if info.Mode().Perm() != 0o660 {
			t.Fatalf("ingress socket mode is %o, want 660", info.Mode().Perm())
		}
		conn, err := net.Dial("unix", backend)
		if err != nil {
			t.Fatalf("dial ingress socket: %v", err)
		}
		defer conn.Close()
		if got := readLine(t, conn); got != "mesh\n" {
			t.Fatalf("unexpected payload %q", got)
		}
	})
}

// TestHelperProcessExit is not a test: it is the child that supervise starts.
func TestHelperProcessExit(t *testing.T) {
	code, err := strconv.Atoi(os.Getenv("REALM_HELPER_TEST_EXIT"))
	if err != nil {
		return
	}
	os.Exit(code)
}

func TestSupervisePropagatesChildStatus(t *testing.T) {
	t.Setenv("REALM_HELPER_TEST_EXIT", "7")
	code, err := supervise([]string{os.Args[0], "-test.run=TestHelperProcessExit"})
	if err != nil {
		t.Fatalf("supervise: %v", err)
	}
	if code != 7 {
		t.Fatalf("supervise returned %d, want the child's 7", code)
	}
}

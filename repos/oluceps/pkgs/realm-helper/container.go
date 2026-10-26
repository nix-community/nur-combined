package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"syscall"
)

// Container paths. They are variables so tests can point them at a temporary
// directory without changing production behaviour.
var (
	routesPath  = "/realm/routes.json"
	backendPath = "/realm/backend/http.sock"
)

// route maps a loopback port inside the container to a mounted egress socket.
type route struct {
	Port   int    `json:"port"`
	Socket string `json:"socket"`
}

// launchCommand prepares the container network view and then runs the real
// entrypoint as its child.
//
// The container runs with network=none, so an application can reach neither the
// host nor the Internet. Before the application starts, this adapter creates
// the local endpoints it expects:
//
//   - every entry of /realm/routes.json becomes a loopback listener that pipes
//     to a mounted egress Unix socket, so a TCP-only client reaches the
//     authenticated proxy without knowing about sockets;
//   - REALM_INGRESS_PORT, when set, publishes /realm/backend/http.sock for an
//     application that serves TCP but cannot create its own Unix listener.
//
// Nothing here terminates TLS: both endpoints already sit behind a proxy that
// enforced the peer identity on the host side.
func launchCommand(args []string) (int, error) {
	if len(args) == 0 {
		return 0, errors.New("launch requires a command")
	}
	if err := startContainerRoutes(); err != nil {
		return 0, err
	}
	return supervise(args)
}

func startContainerRoutes() error {
	raw, err := os.ReadFile(routesPath)
	if err != nil {
		return fmt.Errorf("read %s: %w", routesPath, err)
	}
	var routes []route
	if err := json.Unmarshal(raw, &routes); err != nil {
		return fmt.Errorf("parse %s: %w", routesPath, err)
	}

	for _, entry := range routes {
		listener, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", entry.Port))
		if err != nil {
			return err
		}
		go serveBridge(listener, entry.Socket)
	}

	port := os.Getenv("REALM_INGRESS_PORT")
	if port == "" {
		return nil
	}
	// The application publishes only this socket, which the host mounts from a
	// workload-private directory.
	os.Remove(backendPath)
	listener, err := net.Listen("unix", backendPath)
	if err != nil {
		return err
	}
	if err := os.Chmod(backendPath, 0o660); err != nil {
		return err
	}
	go serveBridge(listener, net.JoinHostPort("127.0.0.1", port))
	return nil
}

// supervise runs the application, forwards termination signals and reaps every
// child process.
//
// The helper may be PID 1 of the container, so it must not leave zombies behind
// when the application orphans a process. The child's exit status becomes the
// helper's exit status.
func supervise(args []string) (int, error) {
	child := exec.Command(args[0], args[1:]...)
	child.Stdin = os.Stdin
	child.Stdout = os.Stdout
	child.Stderr = os.Stderr
	if err := child.Start(); err != nil {
		return 0, err
	}

	forward := make(chan os.Signal, 4)
	signal.Notify(forward, syscall.SIGTERM, syscall.SIGINT, syscall.SIGQUIT, syscall.SIGHUP)
	go func() {
		for received := range forward {
			child.Process.Signal(received)
		}
	}()

	status := make(chan syscall.WaitStatus, 1)
	go reap(child.Process.Pid, status)
	state := <-status

	if state.Signaled() {
		return 128 + int(state.Signal()), nil
	}
	return state.ExitStatus(), nil
}

// reap collects exit statuses until the application exits. Using wait4 directly
// (instead of cmd.Wait) keeps orphaned grandchildren from accumulating.
func reap(child int, status chan<- syscall.WaitStatus) {
	for {
		var state syscall.WaitStatus
		pid, err := syscall.Wait4(-1, &state, 0, nil)
		if errors.Is(err, syscall.EINTR) {
			continue
		}
		if err != nil {
			return
		}
		if pid == child {
			status <- state
			return
		}
	}
}

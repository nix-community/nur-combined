package main

import (
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
)

// fakeSpireAgent writes a stub that records its arguments.
// body controls each healthcheck attempt.
func fakeSpireAgent(t *testing.T, body string) (agent, log string) {
	t.Helper()
	directory := t.TempDir()
	agent = filepath.Join(directory, "spire-agent")
	log = filepath.Join(directory, "calls.log")
	script := "#!/bin/sh\nprintf '%s\\n' \"$*\" >> \"" + log + "\"\n" + body + "\n"
	if err := os.WriteFile(agent, []byte(script), 0o755); err != nil {
		t.Fatalf("write fake agent: %v", err)
	}
	return agent, log
}

// unixSocketPath creates a real Unix socket for the lifetime of the test.
func unixSocketPath(t *testing.T) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "agent.sock")
	listener, err := net.Listen("unix", path)
	if err != nil {
		t.Fatalf("listen unix socket: %v", err)
	}
	t.Cleanup(func() { listener.Close() })
	return path
}

func agentCalls(t *testing.T, log string) []string {
	t.Helper()
	raw, err := os.ReadFile(log)
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		t.Fatalf("read agent calls: %v", err)
	}
	trimmed := strings.TrimSpace(string(raw))
	if trimmed == "" {
		return nil
	}
	return strings.Split(trimmed, "\n")
}

func TestWaitSpireAgentCommandSucceedsWithRealSocket(t *testing.T) {
	agent, log := fakeSpireAgent(t, "exit 0")
	socket := unixSocketPath(t)
	t.Setenv("MAINPID", strconv.Itoa(os.Getpid()))

	code, err := run([]string{"wait-spire-agent", "--spire-agent", agent, "--socket", socket})
	if err != nil || code != 0 {
		t.Fatalf("wait for agent: code %d, error %v", code, err)
	}
	calls := agentCalls(t, log)
	if len(calls) != 1 {
		t.Fatalf("expected one healthcheck, got %v", calls)
	}
	if !strings.Contains(calls[0], "healthcheck -socketPath "+socket) {
		t.Fatalf("unexpected healthcheck invocation: %q", calls[0])
	}
}

func TestWaitSpireAgentHealthyRequiresSocket(t *testing.T) {
	tests := []struct {
		name  string
		setup func(t *testing.T, path string)
	}{
		{"missing", func(t *testing.T, path string) {}},
		{"regular file", func(t *testing.T, path string) {
			if err := os.WriteFile(path, nil, 0o644); err != nil {
				t.Fatalf("write regular file: %v", err)
			}
		}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			agent, log := fakeSpireAgent(t, "exit 0")
			socket := filepath.Join(t.TempDir(), "agent.sock")
			test.setup(t, socket)

			waiter := &spireAgentWaiter{
				agent:    agent,
				socket:   socket,
				pid:      os.Getpid(),
				interval: time.Millisecond,
				timeout:  time.Second,
			}
			if waiter.healthy() {
				t.Fatal("healthy reported success without a socket")
			}
			if calls := agentCalls(t, log); len(calls) != 0 {
				t.Fatalf("healthcheck ran without a socket: %v", calls)
			}
		})
	}
}

func TestWaitSpireAgentRetriesAfterFailedHealthcheck(t *testing.T) {
	marker := filepath.Join(t.TempDir(), "attempted")
	agent, log := fakeSpireAgent(t,
		"if [ -e \""+marker+"\" ]; then exit 0; fi\n: > \""+marker+"\"\nexit 1")
	socket := unixSocketPath(t)

	waiter := &spireAgentWaiter{
		agent:    agent,
		socket:   socket,
		pid:      os.Getpid(),
		interval: time.Millisecond,
		timeout:  time.Second,
	}
	if err := waiter.wait(); err != nil {
		t.Fatalf("wait: %v", err)
	}
	if calls := agentCalls(t, log); len(calls) != 2 {
		t.Fatalf("expected a failed attempt followed by a success, got %v", calls)
	}
}

func TestWaitSpireAgentReturnsWhenMainPIDExits(t *testing.T) {
	agent, log := fakeSpireAgent(t, "exit 0")
	socket := unixSocketPath(t)

	exited := exec.Command("/bin/sh", "-c", "exit 0")
	if err := exited.Run(); err != nil {
		t.Fatalf("start helper process: %v", err)
	}

	waiter := &spireAgentWaiter{
		agent:    agent,
		socket:   socket,
		pid:      exited.Process.Pid,
		interval: 100 * time.Millisecond,
		timeout:  time.Second,
	}
	done := make(chan error, 1)
	go func() { done <- waiter.wait() }()

	select {
	case err := <-done:
		if err == nil || !strings.Contains(err.Error(), "SPIRE agent exited before its API became ready") {
			t.Fatalf("unexpected wait result: %v", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("wait did not return after MAINPID exited")
	}
	if calls := agentCalls(t, log); len(calls) != 0 {
		t.Fatalf("healthcheck ran for an exited agent: %v", calls)
	}
}

func TestWaitSpireAgentHealthcheckTimeout(t *testing.T) {
	agent, log := fakeSpireAgent(t, "exec sleep 30")
	socket := unixSocketPath(t)

	waiter := &spireAgentWaiter{
		agent:    agent,
		socket:   socket,
		pid:      os.Getpid(),
		interval: time.Millisecond,
		timeout:  100 * time.Millisecond,
	}
	start := time.Now()
	if waiter.healthy() {
		t.Fatal("healthy reported success for a stalled healthcheck")
	}
	if elapsed := time.Since(start); elapsed > 2*time.Second {
		t.Fatalf("stalled healthcheck was not cut off: took %s", elapsed)
	}
	if calls := agentCalls(t, log); len(calls) != 1 {
		t.Fatalf("expected one healthcheck invocation, got %v", calls)
	}
}

func TestWaitSpireAgentCommandRejectsBadInput(t *testing.T) {
	socket := unixSocketPath(t)
	validPID := strconv.Itoa(os.Getpid())
	validFlags := []string{"--spire-agent", "/bin/true", "--socket", socket}

	tests := []struct {
		name string
		args []string
		pid  string
		want string
	}{
		{"missing agent", []string{"--socket", socket}, validPID, "spire-agent"},
		{"missing socket", []string{"--spire-agent", "/bin/true"}, validPID, "socket"},
		{"extra positional", append(append([]string{}, validFlags...), "extra"), validPID, "positional"},
		{"empty MAINPID", validFlags, "", "MAINPID"},
		{"invalid MAINPID", validFlags, "not-a-pid", "MAINPID"},
		{"zero MAINPID", validFlags, "0", "MAINPID"},
		{"negative MAINPID", validFlags, "-1", "MAINPID"},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			t.Setenv("MAINPID", test.pid)
			err := waitSpireAgentCommand(test.args)
			if err == nil || !strings.Contains(err.Error(), test.want) {
				t.Fatalf("expected an error containing %q, got %v", test.want, err)
			}
		})
	}
}

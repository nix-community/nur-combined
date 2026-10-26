package main

import (
	"context"
	"errors"
	"flag"
	"os"
	"os/exec"
	"strconv"
	"syscall"
	"time"
)

// waitSpireAgentCommand waits for the Agent API before dependent units start.
// systemd supplies MAINPID and limits the total wait with TimeoutStartSec.
func waitSpireAgentCommand(args []string) error {
	flags := flag.NewFlagSet("wait-spire-agent", flag.ContinueOnError)
	agent := flags.String("spire-agent", "", "Path to the spire-agent binary")
	socket := flags.String("socket", "", "SPIRE Agent Workload API socket")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if err := requireFlags(map[string]string{"spire-agent": *agent, "socket": *socket}); err != nil {
		return err
	}
	if flags.NArg() != 0 {
		return errors.New("wait-spire-agent takes no positional arguments")
	}
	pid, err := strconv.Atoi(os.Getenv("MAINPID"))
	if err != nil || pid <= 0 {
		return errors.New("MAINPID must be a positive process ID")
	}
	waiter := spireAgentWaiter{
		agent:    *agent,
		socket:   *socket,
		pid:      pid,
		interval: 3 * time.Second,
		timeout:  5 * time.Second,
	}
	return waiter.wait()
}

type spireAgentWaiter struct {
	agent    string
	socket   string
	pid      int
	interval time.Duration
	timeout  time.Duration
}

func (w *spireAgentWaiter) wait() error {
	for syscall.Kill(w.pid, 0) == nil {
		if w.healthy() {
			return nil
		}
		time.Sleep(w.interval)
	}
	return errors.New("SPIRE agent exited before its API became ready")
}

func (w *spireAgentWaiter) healthy() bool {
	info, err := os.Stat(w.socket)
	if err != nil || info.Mode()&os.ModeSocket == 0 {
		return false
	}
	ctx, cancel := context.WithTimeout(context.Background(), w.timeout)
	defer cancel()
	return exec.CommandContext(ctx, w.agent, "healthcheck", "-socketPath", w.socket).Run() == nil
}

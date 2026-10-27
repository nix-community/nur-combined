package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"log/slog"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/cilium/ebpf"
)

func main() {
	level := slog.LevelInfo
	if os.Getenv("REALM_AGENT_DEBUG") == "1" {
		level = slog.LevelDebug
	}
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, &slog.HandlerOptions{Level: level})))
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	if e := run(ctx, os.Args[1:]); e != nil {
		fmt.Fprintf(os.Stderr, "realm-agent: %+v\n", e)
		var verifier *ebpf.VerifierError
		if errors.As(e, &verifier) {
			fmt.Fprintf(os.Stderr, "%+v\n", verifier)
		}
		os.Exit(1)
	}
}

func run(ctx context.Context, args []string) error {
	if len(args) == 0 {
		return fmt.Errorf("usage: realm-agent {serve|validate|gate|worker|check-kernel}")
	}
	fs := flag.NewFlagSet(args[0], flag.ContinueOnError)
	configPath := fs.String("config", "", "configuration JSON")
	socket := fs.String("socket", "", "readiness socket")
	uid := fs.Int("uid", 0, "sandbox worker UID")
	gid := fs.Int("gid", 0, "sandbox worker GID")
	cgroup := fs.String("cgroup", "", "dedicated test cgroup")
	if e := fs.Parse(args[1:]); e != nil {
		return e
	}
	switch args[0] {
	case "sandbox":
		return sandboxWorker(*uid, *gid)
	case "worker":
		return runWorker(ctx)
	case "gate":
		if *socket == "" {
			return fmt.Errorf("--socket required")
		}
		ctx, cancel := context.WithTimeout(ctx, 60*time.Second)
		defer cancel()
		return gate(ctx, *socket)
	case "serve", "validate":
		c, e := loadConfig(*configPath)
		if e != nil {
			return e
		}
		if args[0] == "validate" {
			fmt.Printf("valid: %d workload(s)\n", len(c.Workloads))
			return nil
		}
		return serve(ctx, c)
	case "check-kernel":
		if *cgroup == "" || *cgroup == "/sys/fs/cgroup" {
			return fmt.Errorf("--cgroup must name a dedicated test cgroup")
		}
		f, e := os.Open(*cgroup)
		if e != nil {
			return e
		}
		defer f.Close()
		root, e := os.Stat("/sys/fs/cgroup")
		if e != nil {
			return e
		}
		st, e := f.Stat()
		if e != nil {
			return e
		}
		if os.SameFile(root, st) {
			return fmt.Errorf("refusing to probe the cgroup root")
		}
		events, e := os.Open(fmt.Sprintf("/proc/self/fd/%d/cgroup.events", f.Fd()))
		if e != nil {
			return e
		}
		raw, e := io.ReadAll(io.LimitReader(events, 8192))
		events.Close()
		if e != nil {
			return e
		}
		if !strings.Contains(string(raw), "populated 0\n") {
			return fmt.Errorf("refusing to probe a populated cgroup")
		}
		c, e := attachCapture(f, 15001, 15053)
		if e != nil {
			return e
		}
		defer c.Close()
		fmt.Println("all Realm BPF programs loaded and attached")
		return nil
	default:
		return fmt.Errorf("unknown command %q", args[0])
	}
}

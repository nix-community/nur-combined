package main

import (
	"context"
	"errors"
	"flag"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stderr, nil))
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
	defer stop()
	if err := run(ctx, os.Args[1:], logger); err != nil {
		logger.Error("exporter stopped", "stage", "daemon", "reason", "startup_or_serve_failed")
		os.Exit(1)
	}
}
func run(ctx context.Context, args []string, logger *slog.Logger) error {
	mode := "serve"
	if len(args) > 0 && (args[0] == "serve" || args[0] == "validate") {
		mode = args[0]
		args = args[1:]
	}
	flags := flag.NewFlagSet("realm-identity-metrics", flag.ContinueOnError)
	flags.SetOutput(io.Discard)
	path := flags.String("config", "", "Path to the public JSON configuration")
	if flags.Parse(args) != nil || flags.NArg() != 0 || *path == "" {
		return errors.New("use realm-identity-metrics [serve|validate] --config FILE")
	}
	c, err := readConfig(*path)
	if err != nil {
		return err
	}
	if mode == "validate" {
		return nil
	}
	listener, err := net.Listen("tcp", c.ListenAddress)
	if err != nil {
		return errors.New("cannot listen")
	}
	return serveListener(ctx, c, logger, listener)
}

func serveListener(ctx context.Context, c Config, logger *slog.Logger, listener net.Listener) error {
	e := newExporter(c, logger)
	server := &http.Server{Handler: e.handler(), ReadHeaderTimeout: 3 * time.Second, ReadTimeout: 5 * time.Second, WriteTimeout: 5 * time.Second, IdleTimeout: 30 * time.Second, MaxHeaderBytes: 8192, ErrorLog: slog.NewLogLogger(logger.Handler(), slog.LevelError)}
	workerCtx, cancel := context.WithCancel(ctx)
	defer cancel()
	workerDone := make(chan struct{})
	go func() { defer close(workerDone); e.loop(workerCtx) }()
	done := make(chan error, 1)
	go func() { done <- server.Serve(listener) }()
	var err error
	select {
	case err = <-done:
	case <-ctx.Done():
	}
	cancel()
	shutdown, stop := context.WithTimeout(context.Background(), 3*time.Second)
	defer stop()
	_ = server.Shutdown(shutdown)
	_ = server.Close()
	<-workerDone
	if errors.Is(err, http.ErrServerClosed) {
		return nil
	}
	return err
}

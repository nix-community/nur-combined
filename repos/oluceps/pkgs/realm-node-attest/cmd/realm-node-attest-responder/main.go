package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"nyaw.xyz/realm-node-attest"
)

func main() {
	var cfg nodeattest.ResponderConfig
	flag.StringVar(&cfg.FQDN, "fqdn", "", "FQDN for HTTP node attestation")
	flag.IntVar(&cfg.Port, "port", nodeattest.DefaultPort, "HTTP listener port")
	flag.StringVar(&cfg.ControlSocket, "control-socket", "", "Path to the Unix control socket")
	flag.StringVar(&cfg.MetricsAddress, "metrics-address", "", "Literal loopback IP and port for metrics. Empty disables metrics")
	flag.Parse()
	if flag.NArg() != 0 {
		fmt.Fprintln(os.Stderr, "unexpected positional arguments")
		os.Exit(2)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	if err := nodeattest.RunResponder(ctx, cfg); err != nil && !errors.Is(err, context.Canceled) {
		fmt.Fprintln(os.Stderr, `{"@level":"error","@message":"realm_http_responder","component":"responder","stage":"run","reason":"responder_failed"}`)
		os.Exit(1)
	}
}

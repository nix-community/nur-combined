package main

import (
	"errors"
	"flag"
	"net"
)

// bridgeCommand splices a socket-activated listener to one fixed target.
//
// This replaces systemd-socket-proxyd where the target is a workload-private
// loopback address or a container-visible Unix socket. The bridge adds no
// policy of its own: the peer on the far side already authenticated the
// connection, and the socket's ownership decided who may connect.
func bridgeCommand(args []string) error {
	flags := flag.NewFlagSet("bridge", flag.ContinueOnError)
	target := flags.String("target", "", "TCP address or Unix socket path to forward to")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if *target == "" {
		return errors.New("--target is required")
	}

	sockets, err := activatedSockets()
	if err != nil {
		return err
	}
	if len(sockets) == 0 {
		return errors.New("no socket was passed by systemd")
	}

	failures := make(chan error, len(sockets))
	for _, socket := range sockets {
		listener, err := net.FileListener(socket.file)
		socket.file.Close()
		if err != nil {
			return err
		}
		go func() { failures <- serveBridge(listener, *target) }()
	}
	return <-failures
}

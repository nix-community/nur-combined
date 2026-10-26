package main

import (
	"io"
	"net"
	"strings"
	"sync"
	"time"
)

// dialTimeout bounds a single upstream connection attempt.
const dialTimeout = 5 * time.Second

// dialTarget connects to a TCP address or to a Unix socket path.
func dialTarget(target string) (net.Conn, error) {
	if strings.HasPrefix(target, "/") {
		return net.DialTimeout("unix", target, dialTimeout)
	}
	return net.DialTimeout("tcp", target, dialTimeout)
}

// proxy copies both directions and closes each side once its peer is done, so a
// half-closed connection keeps flowing the other way.
func proxy(client, upstream net.Conn) {
	var wait sync.WaitGroup
	wait.Add(2)
	go func() {
		defer wait.Done()
		io.Copy(upstream, client)
		closeWrite(upstream)
	}()
	go func() {
		defer wait.Done()
		io.Copy(client, upstream)
		closeWrite(client)
	}()
	wait.Wait()
	client.Close()
	upstream.Close()
}

// closeWrite sends EOF to the peer without discarding unread data.
func closeWrite(conn net.Conn) {
	switch typed := conn.(type) {
	case *net.TCPConn:
		typed.CloseWrite()
	case *net.UnixConn:
		typed.CloseWrite()
	default:
		conn.Close()
	}
}

// serveBridge accepts connections and splices each one to target.
func serveBridge(listener net.Listener, target string) error {
	for {
		client, err := listener.Accept()
		if err != nil {
			return err
		}
		go func() {
			upstream, err := dialTarget(target)
			if err != nil {
				client.Close()
				return
			}
			proxy(client, upstream)
		}()
	}
}

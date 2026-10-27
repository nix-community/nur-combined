package main

import (
	"context"
	"io"
	"net"
	"path/filepath"
	"testing"
	"time"
)

func TestCONNECTPreservesEarlyTunnelBytes(t *testing.T) {
	path := filepath.Join(t.TempDir(), "proxy.sock")
	l, e := net.Listen("unix", path)
	if e != nil {
		t.Fatal(e)
	}
	defer l.Close()
	go func() {
		c, e := l.Accept()
		if e != nil {
			return
		}
		defer c.Close()
		b := make([]byte, 4096)
		_, _ = c.Read(b)
		_, _ = io.WriteString(c, "HTTP/1.1 200 Connection established\r\nX-Test: yes\r\n\r\nearly-payload")
	}()
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	c, e := dialTunnel(ctx, path, "example.com:443")
	if e != nil {
		t.Fatal(e)
	}
	defer c.Close()
	got, e := io.ReadAll(c)
	if e != nil {
		t.Fatal(e)
	}
	if string(got) != "early-payload" {
		t.Fatalf("lost initial tunnel data: %q", got)
	}
}

func TestCONNECTRejectsHeaderInjection(t *testing.T) {
	if _, e := dialTunnel(context.Background(), "/absent.sock", "host:443\r\nInjected: yes"); e == nil {
		t.Fatal("accepted header injection")
	}
}

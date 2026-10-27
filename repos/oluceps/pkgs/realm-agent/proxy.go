package main

import (
	"bufio"
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"
)

type bufferedConn struct {
	net.Conn
	r *bufio.Reader
}

func (c *bufferedConn) Read(p []byte) (int, error) { return c.r.Read(p) }

func dialTunnel(ctx context.Context, socket, authority string) (net.Conn, error) {
	if strings.ContainsAny(authority, "\r\n \t") {
		return nil, errors.New("invalid CONNECT authority")
	}
	d := net.Dialer{Timeout: 10 * time.Second}
	c, e := d.DialContext(ctx, "unix", socket)
	if e != nil {
		return nil, e
	}
	ok := false
	defer func() {
		if !ok {
			c.Close()
		}
	}()
	deadline := time.Now().Add(10 * time.Second)
	if t, yes := ctx.Deadline(); yes && t.Before(deadline) {
		deadline = t
	}
	c.SetDeadline(deadline)
	if _, e = fmt.Fprintf(c, "CONNECT %s HTTP/1.1\r\nHost: %s\r\n\r\n", authority, authority); e != nil {
		return nil, e
	}
	br := bufio.NewReaderSize(c, 4096)
	// Bound malicious/failed proxy responses without consuming tunnel bytes.
	var header []byte
	for {
		line, err := br.ReadSlice('\n')
		header = append(header, line...)
		if err != nil {
			return nil, err
		}
		if len(header) > 32768 {
			return nil, errors.New("CONNECT response headers too large")
		}
		if bytes.Equal(line, []byte("\r\n")) {
			break
		}
	}
	resp, e := http.ReadResponse(bufio.NewReader(bytes.NewReader(header)), &http.Request{Method: http.MethodConnect})
	if e != nil {
		return nil, e
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("CONNECT returned HTTP %d", resp.StatusCode)
	}
	c.SetDeadline(time.Time{})
	ok = true
	return &bufferedConn{Conn: c, r: br}, nil
}

func splice(a, b net.Conn) {
	defer a.Close()
	defer b.Close()
	var wg sync.WaitGroup
	wg.Add(2)
	copyOne := func(dst, src net.Conn) {
		defer wg.Done()
		_, _ = io.Copy(dst, src)
		if c, ok := dst.(interface{ CloseWrite() error }); ok {
			_ = c.CloseWrite()
		} else if c, ok := dst.(*bufferedConn); ok {
			if h, yes := c.Conn.(interface{ CloseWrite() error }); yes {
				_ = h.CloseWrite()
			}
		}
	}
	go copyOne(a, b)
	go copyOne(b, a)
	wg.Wait()
}

package main

import (
	"net"
	"path/filepath"
	"testing"
)

func TestAgentGateRequiresExplicitReadiness(t *testing.T) {
	for _, response := range []string{"READY\n", "ERROR wrong uid\n", ""} {
		t.Run(response, func(t *testing.T) {
			path := filepath.Join(t.TempDir(), "control.sock")
			l, e := net.Listen("unix", path)
			if e != nil {
				t.Fatal(e)
			}
			defer l.Close()
			go func() {
				c, e := l.Accept()
				if e == nil {
					_, _ = c.Write([]byte(response))
					c.Close()
				}
			}()
			e = waitAgent(path)
			if (e == nil) != (response == "READY\n") {
				t.Fatalf("response %q: %v", response, e)
			}
		})
	}
}

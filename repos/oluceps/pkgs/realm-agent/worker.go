package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"os"
	"sync"
	"time"

	"github.com/cilium/ebpf"
	"golang.org/x/sys/unix"
)

func connectionIdentity(c *net.TCPConn) (connectionKey, error) {
	var k connectionKey
	var inner error
	raw, e := c.SyscallConn()
	if e != nil {
		return k, e
	}
	e = raw.Control(func(fd uintptr) {
		k.Netns, inner = unix.GetsockoptUint64(int(fd), unix.SOL_SOCKET, unix.SO_NETNS_COOKIE)
	})
	if e != nil {
		return k, e
	}
	if inner != nil {
		return k, inner
	}
	remote := c.RemoteAddr().(*net.TCPAddr)
	local := c.LocalAddr().(*net.TCPAddr)
	k.SourcePort = uint32(remote.Port)
	k.ProxyPort = uint32(local.Port)
	if ip := remote.IP.To4(); ip != nil {
		k.Family = unix.AF_INET
		copy(k.Source[:4], ip)
	} else {
		k.Family = unix.AF_INET6
		copy(k.Source[:], remote.IP.To16())
	}
	return k, nil
}

func originalDestination(m *ebpf.Map, c *net.TCPConn) (destination, error) {
	k, e := connectionIdentity(c)
	if e != nil {
		return destination{}, e
	}
	var d destination
	// The active-established callback and accept can run on different CPUs.
	// Never forward if the reverse mapping is missing or has been evicted.
	for i := 0; i < 20; i++ {
		e = m.Lookup(&k, &d)
		if e == nil {
			return d, nil
		}
		if !errors.Is(e, ebpf.ErrKeyNotExist) {
			return d, e
		}
		time.Sleep(time.Millisecond)
	}
	return d, fmt.Errorf("no original destination for %s: %w", c.RemoteAddr(), e)
}

func runWorker(ctx context.Context) error {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	lease := os.NewFile(7, "parent-liveness")
	defer lease.Close()
	go func() { _, _ = io.Copy(io.Discard, lease); cancel() }()
	configFile := os.NewFile(6, "worker-config")
	defer configFile.Close()
	var wc workerConfiguration
	if e := json.NewDecoder(configFile).Decode(&wc); e != nil {
		return e
	}
	w := wc.Workload
	if e := w.validate(); e != nil {
		return e
	}
	m, e := ebpf.NewMapFromFD(4)
	if e != nil {
		return e
	}
	defer m.Close()
	ready := os.NewFile(5, "worker-ready")
	defer ready.Close()
	if os.Geteuid() == 0 {
		return errors.New("worker must not run as root")
	}
	if e := unix.Prctl(unix.PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0); e != nil {
		return e
	}
	if e := unix.Prctl(unix.PR_SET_DUMPABLE, 0, 0, 0, 0); e != nil {
		return e
	}
	interfaces, e := net.Interfaces()
	if e != nil {
		return e
	}
	for _, iface := range interfaces {
		if fallbackTunnelKinds[iface.Name] != "" && iface.Flags&net.FlagUp == 0 {
			addresses, err := iface.Addrs()
			if err == nil && len(addresses) == 0 {
				continue // Controller also checked the tunnel's kind and endpoints.
			}
		}
		if iface.Flags&net.FlagLoopback == 0 && iface.Name != "realm0" {
			return fmt.Errorf("refusing namespace with non-loopback interface %s", iface.Name)
		}
	}
	r := newResolver(w)
	r.ctx = ctx
	servers, e := startDNS(r, w.DNSBase)
	if e != nil {
		return e
	}
	defer servers.Close()
	var listeners []*net.TCPListener
	for _, network := range []string{"tcp4", "tcp6"} {
		host := "127.0.0.1"
		if network == "tcp6" {
			host = "::1"
		}
		l, e := net.ListenTCP(network, &net.TCPAddr{IP: net.ParseIP(host), Port: int(w.TCPPort)})
		if e != nil {
			for _, l := range listeners {
				l.Close()
			}
			return e
		}
		listeners = append(listeners, l)
	}
	var active sync.Map
	go func() {
		<-ctx.Done()
		for _, l := range listeners {
			l.Close()
		}
		active.Range(func(k, v interface{}) bool { k.(net.Conn).Close(); return true })
	}()
	limit := make(chan struct{}, w.MaxConnections)
	for _, l := range listeners {
		go func(l *net.TCPListener) {
			for {
				c, e := l.AcceptTCP()
				if e != nil {
					return
				}
				select {
				case limit <- struct{}{}:
				default:
					c.Close()
					continue
				}
				active.Store(c, true)
				go func() {
					defer func() { active.Delete(c); <-limit; c.Close() }()
					d, e := originalDestination(m, c)
					if e != nil {
						slog.Warn("reject unassociated connection", "workload", w.Name, "error", e)
						return
					}
					a, e := d.addr()
					if e != nil {
						return
					}
					if a.Port() == 53 {
						r.tcp(c)
						return
					}
					socket, e := w.target(a)
					if e != nil {
						slog.Warn("deny destination", "workload", w.Name, "target", a, "error", e)
						return
					}
					var upstream net.Conn
					if socket == w.InternetSocket {
						upstream, e = dialTunnel(ctx, socket, a.String())
					} else {
						dialer := net.Dialer{Timeout: 10 * time.Second}
						upstream, e = dialer.DialContext(ctx, "unix", socket)
					}
					if e != nil {
						slog.Warn("egress failed", "workload", w.Name, "target", a, "error", e)
						return
					}
					active.Store(upstream, true)
					defer active.Delete(upstream)
					slog.Debug("forward", "workload", w.Name, "target", a)
					splice(c, upstream)
				}()
			}
		}(l)
	}
	if _, e = ready.WriteString("READY\n"); e != nil {
		return e
	}
	ready.Close()
	<-ctx.Done()
	return nil
}

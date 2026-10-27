package main

import (
	"bufio"
	"context"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"golang.org/x/sys/unix"
)

type instance struct {
	capture       *capture
	cgroup, netns *os.File
	command       *exec.Cmd
	done          chan struct{}
	waitErr       error
	lease         *os.File
	cancel        context.CancelFunc
	key           string
	resources     *os.File
	emptySince    time.Time
}

func (i *instance) close() {
	// Leave capture in place until the forwarding worker has stopped.
	i.lease.Close()
	i.cancel()
	select {
	case <-i.done:
	case <-time.After(3 * time.Second):
		_ = i.command.Process.Kill()
		<-i.done
	}
	i.capture.Close()
	i.cgroup.Close()
	i.netns.Close()
	i.resources.Close()
}

// ExecStartPre can leave a unit briefly empty between the gate and ExecStart.
// Retain its state/capture across that gap so a controller restart can still
// discover the application once it starts. Real stops release after 30 seconds.
func (i *instance) expiredEmpty(now time.Time) bool {
	if populated(i.cgroup) {
		i.emptySince = time.Time{}
		return false
	}
	if i.emptySince.IsZero() {
		i.emptySince = now
		return false
	}
	return now.Sub(i.emptySince) >= 30*time.Second
}

type controller struct {
	config              configuration
	workload            workload
	mu                  sync.Mutex
	current             *instance
	uid, gid, workerUID int
	workerGroups        *os.File
}

func numericUser(name string) (int, error) {
	u, e := user.Lookup(name)
	if e != nil {
		return 0, e
	}
	return strconv.Atoi(u.Uid)
}
func numericGroup(name string) (int, error) {
	g, e := user.LookupGroup(name)
	if e != nil {
		return 0, e
	}
	return strconv.Atoi(g.Gid)
}

// Pin the socket's original peer, not a fresh lookup of its numeric PID.
func peerProcess(c *net.UnixConn) (*os.File, *unix.Ucred, error) {
	var cred *unix.Ucred
	var inner error
	pidfd := -1
	raw, e := c.SyscallConn()
	if e != nil {
		return nil, nil, e
	}
	e = raw.Control(func(fd uintptr) {
		cred, inner = unix.GetsockoptUcred(int(fd), unix.SOL_SOCKET, unix.SO_PEERCRED)
		if inner == nil {
			pidfd, inner = unix.GetsockoptInt(int(fd), unix.SOL_SOCKET, unix.SO_PEERPIDFD)
		}
	})
	if pidfd >= 0 {
		defer unix.Close(pidfd)
	}
	if e != nil {
		return nil, nil, e
	}
	if inner != nil {
		return nil, nil, fmt.Errorf("pin gate peer (SO_PEERPIDFD required): %w", inner)
	}
	alive := func() error {
		p := []unix.PollFd{{Fd: int32(pidfd), Events: unix.POLLIN}}
		n, e := unix.Poll(p, 0)
		if e != nil {
			return e
		}
		if n != 0 {
			return errors.New("gate peer exited")
		}
		return nil
	}
	if e := alive(); e != nil {
		return nil, nil, e
	}
	f, e := os.Open(fmt.Sprintf("/proc/%d", cred.Pid))
	if e != nil {
		return nil, nil, e
	}
	// If the original process died before proc was opened, reject even if its
	// number already refers to another process. After this point openat uses
	// the pinned original proc directory and cannot follow subsequent reuse.
	if e := alive(); e != nil {
		f.Close()
		return nil, nil, e
	}
	return f, cred, nil
}

func openProcessFile(proc *os.File, path string) (*os.File, error) {
	fd, e := unix.Openat(int(proc.Fd()), path, unix.O_RDONLY|unix.O_CLOEXEC, 0)
	if e != nil {
		return nil, e
	}
	return os.NewFile(uintptr(fd), path), nil
}

// Native units are identified within the host system manager, never by a
// same-named unit below a user manager or another delegated service. Slice
// ancestors are controlled by systemd. Capture the whole unit, including an
// ExecStartPre .control subgroup, so subsequent application processes inherit it.
func workloadCgroup(path, unit string) (string, error) {
	if path == "" || path == "/" || !strings.HasPrefix(path, "/") || filepath.Clean(path) != path {
		return "", errors.New("peer must have a dedicated cgroup v2 group")
	}
	if unit == "" {
		return path, nil
	}
	parts := strings.Split(strings.TrimPrefix(path, "/"), "/")
	for n, part := range parts {
		if part == unit {
			return "/" + strings.Join(parts[:n+1], "/"), nil
		}
		if !strings.HasSuffix(part, ".slice") {
			break
		}
	}
	return "", fmt.Errorf("peer does not belong to system unit %s", unit)
}

func processNetwork(proc *os.File, unit string) (*os.File, *os.File, string, error) {
	f, e := openProcessFile(proc, "cgroup")
	if e != nil {
		return nil, nil, "", e
	}
	raw, e := io.ReadAll(io.LimitReader(f, 8192))
	f.Close()
	if e != nil {
		return nil, nil, "", e
	}
	path := ""
	for _, line := range strings.Split(string(raw), "\n") {
		if strings.HasPrefix(line, "0::/") {
			path = strings.TrimPrefix(line, "0::")
			break
		}
	}
	path, e = workloadCgroup(path, unit)
	if e != nil {
		return nil, nil, "", e
	}
	cg, e := os.Open("/sys/fs/cgroup" + path)
	if e != nil {
		return nil, nil, "", e
	}
	ns, e := openProcessFile(proc, "ns/net")
	if e != nil {
		cg.Close()
		return nil, nil, "", e
	}
	var a, b unix.Stat_t
	if e = unix.Fstat(int(cg.Fd()), &a); e != nil {
		cg.Close()
		ns.Close()
		return nil, nil, "", e
	}
	if e = unix.Fstat(int(ns.Fd()), &b); e != nil {
		cg.Close()
		ns.Close()
		return nil, nil, "", e
	}
	// A managed application must have a separate network namespace. This is
	// also the fallback boundary if a BPF program or controller disappears.
	host, e := os.Open("/proc/self/ns/net")
	if e != nil {
		cg.Close()
		ns.Close()
		return nil, nil, "", e
	}
	var h unix.Stat_t
	e = unix.Fstat(int(host.Fd()), &h)
	host.Close()
	if e != nil || h.Ino == b.Ino {
		cg.Close()
		ns.Close()
		return nil, nil, "", errors.New("refusing host network namespace")
	}
	return cg, ns, fmt.Sprintf("%d:%d", a.Ino, b.Ino), nil
}

func populated(cg *os.File) bool {
	fd, e := unix.Openat(int(cg.Fd()), "cgroup.events", unix.O_RDONLY|unix.O_CLOEXEC, 0)
	if e != nil {
		return false
	}
	f := os.NewFile(uintptr(fd), "cgroup.events")
	defer f.Close()
	b, e := io.ReadAll(io.LimitReader(f, 4096))
	return e == nil && strings.Contains(string(b), "populated 1")
}

func (c *controller) prepare(ctx context.Context, conn *net.UnixConn) error {
	proc, cred, e := peerProcess(conn)
	if e != nil {
		return e
	}
	defer proc.Close()
	if int(cred.Uid) != c.uid {
		return fmt.Errorf("peer uid %d is not configured uid %d", cred.Uid, c.uid)
	}
	cg, ns, key, e := processNetwork(proc, c.workload.Unit)
	if e != nil {
		return e
	}
	owned := false
	defer func() {
		if !owned {
			cg.Close()
			ns.Close()
		}
	}()
	c.mu.Lock()
	defer c.mu.Unlock()
	if i := c.current; i != nil {
		select {
		case <-i.done:
			i.close()
			c.current = nil
		default:
			if key == i.key {
				return nil
			}
			if populated(i.cgroup) {
				return errors.New("workload already active in a different cgroup or network namespace")
			}
			i.close()
			c.current = nil
		}
	}
	i, e := c.start(ctx, cg, ns, key)
	if e != nil {
		return e
	}
	c.current = i
	owned = true
	if e := c.saveState(); e != nil {
		c.current.close()
		c.current = nil
		return e
	}
	slog.Info("workload captured", "workload", c.workload.Name, "peerPID", cred.Pid, "namespace", key)
	return nil
}

func (c *controller) start(ctx context.Context, cg, ns *os.File, key string) (*instance, error) {
	w := c.workload
	if e := c.setupNetwork(ctx, ns); e != nil {
		return nil, e
	}
	cap, e := attachCapture(cg, w.TCPPort, w.DNSBase)
	if e != nil {
		return nil, e
	}
	ok := false
	defer func() {
		if !ok {
			cap.Close()
		}
	}()
	// The app is blocked on its gate while programs attach and listeners start.
	workerCtx, cancel := context.WithCancel(ctx)
	readyR, readyW, e := os.Pipe()
	if e != nil {
		cancel()
		return nil, e
	}
	defer readyR.Close()
	defer readyW.Close()
	configR, e := sealedWorkerConfig(w, c.config.CABundle)
	if e != nil {
		cancel()
		return nil, e
	}
	defer configR.Close()
	leaseR, leaseW, e := os.Pipe()
	if e != nil {
		cancel()
		return nil, e
	}
	defer leaseR.Close()
	defer func() {
		if !ok {
			leaseW.Close()
		}
	}()
	exe, e := os.Executable()
	if e != nil {
		cancel()
		return nil, e
	}
	mapFD, e := unix.Dup(cap.collection.Maps["connections"].FD())
	if e != nil {
		cancel()
		return nil, e
	}
	unix.CloseOnExec(mapFD)
	mapFile := os.NewFile(uintptr(mapFD), "connections")
	defer mapFile.Close()
	resources, e := workerCgroup(c.workerGroups, w)
	if e != nil {
		cancel()
		return nil, e
	}
	defer func() {
		if !ok {
			resources.Close()
		}
	}()
	// nsenter enters before exec, so every thread of the Go runtime starts in
	// the right namespace. Calling setns on one Go thread is not sufficient.
	cmd := exec.CommandContext(workerCtx, c.config.NamespaceTool, "--net=/proc/self/fd/3", "--", exe, "sandbox", "--uid", strconv.Itoa(c.workerUID), "--gid", strconv.Itoa(c.gid))
	cmd.Dir = "/"
	cmd.Env = []string{"PATH=/run/current-system/sw/bin", "GOMAXPROCS=2"}
	cmd.ExtraFiles = []*os.File{ns, mapFile, readyW, configR, leaseR, resources}
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if e = cmd.Start(); e != nil {
		cancel()
		return nil, e
	}
	i := &instance{capture: cap, cgroup: cg, netns: ns, command: cmd, done: make(chan struct{}), cancel: cancel, key: key, lease: leaseW, resources: resources}
	go func() { i.waitErr = cmd.Wait(); close(i.done) }()
	readyW.Close()
	configR.Close()
	leaseR.Close()
	result := make(chan error, 1)
	go func() {
		line, e := bufio.NewReader(io.LimitReader(readyR, 256)).ReadString('\n')
		if e == nil && line != "READY\n" {
			e = errors.New("invalid worker readiness response")
		}
		result <- e
	}()
	select {
	case e = <-result:
	case <-time.After(15 * time.Second):
		e = errors.New("worker readiness timeout")
	case <-ctx.Done():
		e = ctx.Err()
	}
	if e != nil {
		cancel()
		<-i.done
		return nil, e
	}
	ok = true
	return i, nil
}

func (c *controller) serve(ctx context.Context, listener *net.UnixListener) {
	go func() { <-ctx.Done(); listener.Close() }()
	limit := make(chan struct{}, 16)
	for {
		conn, e := listener.AcceptUnix()
		if e != nil {
			return
		}
		select {
		case limit <- struct{}{}:
		default:
			conn.Close()
			continue
		}
		go func() {
			defer conn.Close()
			defer func() { <-limit }()
			conn.SetDeadline(time.Now().Add(30 * time.Second))
			e := c.prepare(ctx, conn)
			if e != nil {
				slog.Error("gate refused", "workload", c.workload.Name, "error", e)
				fmt.Fprintln(conn, "ERROR "+e.Error())
				return
			}
			fmt.Fprintln(conn, "READY")
		}()
	}
}

func serve(ctx context.Context, config configuration) error {
	if os.Geteuid() != 0 {
		return errors.New("serve requires host root privileges")
	}
	ctx, cancel := context.WithCancel(ctx)
	groups, e := delegatedWorkerRoot()
	if e != nil {
		cancel()
		return e
	}
	defer groups.Close()
	var controllers []*controller
	var listeners []*net.UnixListener
	var reconciliations sync.WaitGroup
	defer func() {
		cancel()
		for _, l := range listeners {
			l.Close()
		}
		reconciliations.Wait()
		for _, c := range controllers {
			c.mu.Lock()
			if c.current != nil {
				c.current.close()
			}
			c.mu.Unlock()
		}
	}()
	for _, w := range config.Workloads {
		uid, e := numericUser(w.User)
		if e != nil {
			return e
		}
		gid, e := numericGroup(w.Group)
		if e != nil {
			return e
		}
		workerUID, e := numericUser(w.WorkerUser)
		if e != nil {
			return e
		}
		if uid == 0 || gid == 0 || workerUID == 0 || uid == workerUID {
			return errors.New("unsafe account IDs")
		}
		for _, other := range controllers {
			if uid == other.uid && (w.Unit == "" || other.workload.Unit == "" || w.Unit == other.workload.Unit) {
				return errors.New("shared application UID requires distinct attested system units")
			}
		}
		if e = os.MkdirAll(filepath.Dir(w.Socket), 0750); e != nil {
			return e
		}
		if e = os.Chown(filepath.Dir(w.Socket), 0, gid); e != nil {
			return e
		}
		if st, e := os.Lstat(w.Socket); e == nil {
			if st.Mode()&os.ModeSocket == 0 {
				return errors.New("control path is not a socket")
			}
			if e = os.Remove(w.Socket); e != nil {
				return e
			}
		} else if !os.IsNotExist(e) {
			return e
		}
		l, e := net.ListenUnix("unix", &net.UnixAddr{Name: w.Socket, Net: "unix"})
		if e != nil {
			return e
		}
		listeners = append(listeners, l)
		if e = os.Chown(w.Socket, 0, gid); e != nil {
			return e
		}
		if e = os.Chmod(w.Socket, 0660); e != nil {
			return e
		}
		c := &controller{config: config, workload: w, uid: uid, gid: gid, workerUID: workerUID, workerGroups: groups}
		controllers = append(controllers, c)
		go c.serve(ctx, l)
		reconciliations.Add(1)
		go func() { defer reconciliations.Done(); c.reconcile(ctx) }()
	}
	notifyReady()
	<-ctx.Done()
	return nil
}

// Each workload reconciles independently. Slow setup, occupied listeners, or a
// malformed state file must neither fail host startup nor block other workers.
func (c *controller) reconcile(ctx context.Context) {
	for {
		c.mu.Lock()
		if ctx.Err() != nil {
			c.mu.Unlock()
			return
		}
		if i := c.current; i != nil {
			select {
			case <-i.done:
				slog.Error("worker exited", "workload", c.workload.Name, "error", i.waitErr)
				i.close()
				c.current = nil
			default:
			}
			if c.current != nil && i.expiredEmpty(time.Now()) {
				i.close()
				c.current = nil
				_ = os.Remove(c.statePath())
				slog.Info("released empty workload", "workload", c.workload.Name)
			}
		}
		if c.current == nil {
			if e := c.recover(ctx); e != nil {
				slog.Error("worker recovery failed", "workload", c.workload.Name, "error", e)
			}
		}
		c.mu.Unlock()
		select {
		case <-ctx.Done():
			return
		case <-time.After(2 * time.Second):
		}
	}
}

func gate(ctx context.Context, path string) error {
	for {
		d := net.Dialer{Timeout: time.Second}
		conn, e := d.DialContext(ctx, "unix", path)
		if e == nil {
			conn.SetDeadline(time.Now().Add(30 * time.Second))
			line, err := bufio.NewReader(io.LimitReader(conn, 4096)).ReadString('\n')
			conn.Close()
			if err != nil {
				return err
			}
			if line != "READY\n" {
				return fmt.Errorf("agent refused: %s", strings.TrimSpace(line))
			}
			return nil
		}
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(100 * time.Millisecond):
		}
	}
}

func notifyReady() {
	if p := os.Getenv("NOTIFY_SOCKET"); p != "" {
		c, e := net.DialUnix("unixgram", nil, &net.UnixAddr{Name: p, Net: "unixgram"})
		if e == nil {
			_, _ = c.Write([]byte("READY=1"))
			c.Close()
		}
	}
}

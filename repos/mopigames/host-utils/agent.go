package main

import (
	"bufio"
	"crypto/subtle"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"
)

type Agent struct {
	cfg *Config

	mu   sync.Mutex
	seen map[string]int // server -> consecutive failed reachability checks
}

func NewAgent(cfg *Config) *Agent {
	return &Agent{cfg: cfg, seen: map[string]int{}}
}

func (a *Agent) Serve(port int) error {
	ln, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		return err
	}
	defer ln.Close()

	t, ok := findTool()
	if ok {
		logf("USB/IP client: %s (%s)", t.Path, t.Kind)
	} else {
		logf("no USB/IP client installed yet -- Moonlight OS can ask for one with the install op")
	}
	logf("mlos-host-utils %s listening on :%d", Version, port)

	go a.janitor()

	for {
		conn, err := ln.Accept()
		if err != nil {
			if ne, ok := err.(net.Error); ok && ne.Timeout() {
				continue
			}
			return err
		}
		go a.handle(conn)
	}
}

func (a *Agent) handle(conn net.Conn) {
	defer conn.Close()

	peer, _, err := net.SplitHostPort(conn.RemoteAddr().String())
	if err != nil {
		return
	}
	// IPv6 link-local arrives as fe80::1%eth0; usbip wants it without the
	// zone, and a tailnet or LAN address never has one anyway.
	if i := strings.IndexByte(peer, '%'); i >= 0 {
		peer = peer[:i]
	}
	vlogf("connection from %s", peer)

	r := bufio.NewReader(conn)
	w := bufio.NewWriter(conn)
	enc := json.NewEncoder(w)

	for {
		// Generous: Moonlight OS holds a connection open between
		// hotplug events, which on a quiet evening is a long time.
		conn.SetReadDeadline(time.Now().Add(10 * time.Minute))

		line, err := r.ReadBytes('\n')
		if err != nil {
			return
		}
		line = trimSpaceBytes(line)
		if len(line) == 0 {
			continue
		}

		var req Request
		resp := Response{V: ProtocolVersion}
		if err := json.Unmarshal(line, &req); err != nil {
			resp.Error, resp.Code = "malformed request", CodeBadRequest
		} else {
			resp = a.dispatch(peer, req)
		}
		resp.V = ProtocolVersion
		resp.ID = req.ID

		conn.SetWriteDeadline(time.Now().Add(30 * time.Second))
		if err := enc.Encode(&resp); err != nil {
			return
		}
		if err := w.Flush(); err != nil {
			return
		}
	}
}

func trimSpaceBytes(b []byte) []byte {
	for len(b) > 0 && (b[len(b)-1] == '\n' || b[len(b)-1] == '\r' || b[len(b)-1] == ' ') {
		b = b[:len(b)-1]
	}
	for len(b) > 0 && (b[0] == ' ' || b[0] == '\t') {
		b = b[1:]
	}
	return b
}

func fail(msg, code string) Response {
	return Response{V: ProtocolVersion, OK: false, Error: msg, Code: code}
}

func ok(data any) Response {
	return Response{V: ProtocolVersion, OK: true, Data: data}
}

func (a *Agent) dispatch(peer string, req Request) Response {
	// Normalised first, so the dashes the code is printed with and the
	// case someone typed it in do not matter; constant time after that, so
	// the port cannot be used to guess it a character at a time.
	if subtle.ConstantTimeCompare([]byte(NormaliseToken(req.Token)), []byte(a.cfg.Token)) != 1 {
		logf("rejected %s from %s: bad pairing code", req.Op, peer)
		// A second per wrong answer.  The code is 80 bits, so this is the
		// difference between "not guessable" and "not guessable by a
		// considerable margin" -- and it costs a legitimate client, which
		// gets the code right, nothing at all.
		time.Sleep(time.Second)
		return fail("wrong pairing code -- pair this host PC again from the Moonlight OS menu", CodeBadToken)
	}
	if req.V > ProtocolVersion {
		return fail(fmt.Sprintf("this agent speaks protocol %d, the client wants %d -- update mlos-host-utils",
			ProtocolVersion, req.V), CodeBadRequest)
	}

	switch req.Op {
	case "ping":
		return a.opPing()
	case "install":
		return a.opInstall()
	case "sync":
		return a.opSync(peer, req)
	case "attach":
		return a.opAttach(peer, req)
	case "detach":
		return a.opDetach(peer, req)
	case "list":
		return a.opList(peer)
	default:
		return fail("unknown op "+strconv.Quote(req.Op), CodeUnknownOp)
	}
}

func (a *Agent) opPing() Response {
	host, _ := os.Hostname()
	res := PingResult{
		Agent:    "mlos-host-utils",
		Version:  Version,
		Protocol: ProtocolVersion,
		OS:       runtime.GOOS,
		Arch:     runtime.GOARCH,
		Hostname: host,
	}
	if t, present := findTool(); present {
		res.ClientTool = ToolInfo{Present: true, Path: t.Path, Kind: t.Kind, Version: t.Version()}
		if list, err := t.Attached(); err == nil {
			res.Attached = len(list)
		}
	} else {
		res.ClientTool = ToolInfo{Kind: defaultToolKind()}
	}
	res.NeedsReboot = needsReboot()
	return ok(res)
}

func defaultToolKind() string {
	if runtime.GOOS == "windows" {
		return "usbip-win2"
	}
	return "usbip"
}

func (a *Agent) opInstall() Response {
	res, err := ensureClient()
	if err != nil && !res.Installed {
		msg := res.Message
		if msg == "" {
			msg = err.Error()
		}
		return fail(msg, CodeNotInstalled)
	}
	for _, act := range res.Actions {
		logf("install: %s", act)
	}
	return ok(res)
}

// tool resolves the client, turning "not installed" into an error code the
// Moonlight OS menu knows how to offer a fix for rather than a raw string.
func (a *Agent) tool() (Tool, *Response) {
	t, present := findTool()
	if !present {
		r := fail("no USB/IP client on this machine yet", CodeNotInstalled)
		return Tool{}, &r
	}
	if needsReboot() {
		r := fail("the USB/IP driver is installed but not live until this PC reboots", CodeNeedsReboot)
		return Tool{}, &r
	}
	return t, nil
}

func serverFor(peer, override string) string {
	if override != "" {
		return override
	}
	return peer
}

func (a *Agent) opSync(peer string, req Request) Response {
	var args SyncArgs
	if len(req.Args) > 0 {
		if err := json.Unmarshal(req.Args, &args); err != nil {
			return fail("malformed sync args", CodeBadRequest)
		}
	}
	t, errResp := a.tool()
	if errResp != nil {
		// An empty offer with nothing installed is not a problem worth
		// reporting -- there is nothing to do either way.
		if len(args.Devices) == 0 && errResp.Code == CodeNotInstalled {
			return ok(SyncResult{Attached: []string{}, Detached: []string{}, Failed: []FailedItem{}, Current: []Attached{}})
		}
		return *errResp
	}

	server := serverFor(peer, args.Server)
	res, err := t.Sync(server, args.Port, args.Devices)
	if err != nil {
		return fail(err.Error(), CodeToolFailed)
	}

	a.mu.Lock()
	a.seen[server] = 0
	a.mu.Unlock()

	return ok(res)
}

func (a *Agent) opAttach(peer string, req Request) Response {
	var args AttachArgs
	if err := json.Unmarshal(req.Args, &args); err != nil || args.BusID == "" {
		return fail("attach needs a busid", CodeBadRequest)
	}
	t, errResp := a.tool()
	if errResp != nil {
		return *errResp
	}
	server := serverFor(peer, args.Server)

	toolMu.Lock()
	err := t.Attach(server, args.Port, args.BusID)
	toolMu.Unlock()
	if err != nil {
		return fail(err.Error(), CodeToolFailed)
	}
	logf("attached %s from %s", args.BusID, server)
	list, _ := t.AttachedFrom(server)
	return ok(map[string]any{"busid": args.BusID, "current": list})
}

func (a *Agent) opDetach(peer string, req Request) Response {
	var args DetachArgs
	if len(req.Args) > 0 {
		if err := json.Unmarshal(req.Args, &args); err != nil {
			return fail("malformed detach args", CodeBadRequest)
		}
	}
	t, errResp := a.tool()
	if errResp != nil {
		return *errResp
	}

	if args.All {
		done, err := t.DetachAll(peer)
		if err != nil {
			return fail(err.Error(), CodeToolFailed)
		}
		logf("detached %d device(s) from %s", len(done), peer)
		return ok(map[string]any{"detached": done})
	}
	if args.BusID == "" {
		return fail("detach needs a busid, or all:true", CodeBadRequest)
	}
	if err := t.DetachBusID(peer, args.BusID); err != nil {
		return fail(err.Error(), CodeToolFailed)
	}
	logf("detached %s from %s", args.BusID, peer)
	return ok(map[string]any{"detached": []string{args.BusID}})
}

func (a *Agent) opList(peer string) Response {
	t, errResp := a.tool()
	if errResp != nil {
		return *errResp
	}
	list, err := t.AttachedFrom(peer)
	if err != nil && list == nil {
		return fail(err.Error(), CodeToolFailed)
	}
	if list == nil {
		list = []Attached{}
	}
	return ok(map[string]any{"attached": list})
}

// janitor cleans up after a Moonlight OS box that left without saying so.
//
// Pulling the power on the thin client -- or carrying a laptop out of Wi-Fi
// range -- is not a detach.  The device stays in the port table forever,
// wedged, and the next attach of the same wheel lands on a second port while
// the host keeps talking to the dead one.  Nothing else notices, so this
// does: when a server stops answering on the USB/IP port for a minute, its
// devices go.
//
// One minute rather than one failed probe, because a Wi-Fi roam or a
// tailnet reconnect is a few seconds of nothing and must not cost you the
// wheel mid-corner.
func (a *Agent) janitor() {
	const (
		interval = 20 * time.Second
		giveUp   = 3 // consecutive failures ~= 60s
	)
	for {
		time.Sleep(interval)

		t, present := findTool()
		if !present {
			continue
		}
		list, err := t.Attached()
		if err != nil && list == nil {
			continue
		}

		servers := map[string]bool{}
		for _, at := range list {
			servers[at.Server] = true
		}

		a.mu.Lock()
		for s := range a.seen {
			if !servers[s] {
				delete(a.seen, s)
			}
		}
		a.mu.Unlock()

		for s := range servers {
			addr := net.JoinHostPort(s, strconv.Itoa(DefaultUSBIPPort))
			c, err := net.DialTimeout("tcp", addr, 4*time.Second)
			if err == nil {
				c.Close()
				a.mu.Lock()
				a.seen[s] = 0
				a.mu.Unlock()
				continue
			}

			a.mu.Lock()
			a.seen[s]++
			n := a.seen[s]
			a.mu.Unlock()

			vlogf("%s did not answer on %d (%d/%d)", s, DefaultUSBIPPort, n, giveUp)
			if n < giveUp {
				continue
			}
			logf("%s has been unreachable for ~%s, detaching its devices", s, time.Duration(giveUp)*interval)
			if done, err := t.DetachAll(s); err == nil {
				logf("detached %d stale device(s) from %s", len(done), s)
			}
			a.mu.Lock()
			delete(a.seen, s)
			a.mu.Unlock()
		}
	}
}

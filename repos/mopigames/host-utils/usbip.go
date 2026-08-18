package main

import (
	"fmt"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"
)

// The USB/IP client, whichever one this machine has.
//
// Linux and Windows are the same program twice: usbip-win2 deliberately
// copies the upstream CLI, verbs and output format alike, so one parser
// covers both.  Everything that actually differs -- where the binary lives,
// how it gets installed, what has to be loaded first -- is in platform_*.go.
type Tool struct {
	Path string
	Kind string // "usbip" (Linux) | "usbip-win2" (Windows)
}

// usbip attach/detach mutate a global table, and two of them racing produces
// duplicate ports and orphaned attachments.  Every op goes through here.
var toolMu sync.Mutex

func (t Tool) run(args ...string) (string, error) {
	cmd := exec.Command(t.Path, args...)
	hideWindow(cmd)
	out, err := cmd.CombinedOutput()
	text := strings.TrimSpace(string(out))
	if err != nil {
		if text == "" {
			return "", err
		}
		return text, fmt.Errorf("%s: %s", strings.Join(args, " "), firstLine(text))
	}
	return text, nil
}

func firstLine(s string) string {
	if i := strings.IndexByte(s, '\n'); i >= 0 {
		return strings.TrimSpace(s[:i])
	}
	return s
}

func (t Tool) Version() string {
	out, err := t.run("version")
	if err != nil {
		return ""
	}
	return firstLine(out)
}

// Attach imports one device.  usbip grew --tcp-port late and usbip-win2 has
// its own spelling, so the flag is only passed when it is actually needed --
// on the default port the plain form works everywhere.
func (t Tool) Attach(server string, port int, busid string) error {
	args := []string{"attach", "-r", server, "-b", busid}
	if port != 0 && port != DefaultUSBIPPort {
		args = append(args, "--tcp-port", strconv.Itoa(port))
	}
	_, err := t.run(args...)
	return err
}

func (t Tool) DetachPort(port int) error {
	_, err := t.run("detach", "-p", strconv.Itoa(port))
	return err
}

var (
	rePortLine = regexp.MustCompile(`^\s*Port\s+(\d+)\s*:`)
	// "1-1 -> usbip://192.168.1.5:3240/1-2", and the IPv6 form
	// "usbip://[fd7a::1]:3240/1-2".
	reImport = regexp.MustCompile(`usbip://(\[[^\]]+\]|[^:/\s]+)(?::(\d+))?/(\S+)`)
)

// Attached parses `usbip port`.  Sample, both platforms:
//
//	Imported USB devices
//	====================
//	Port 00: <Port in Use> at Full Speed(12Mbps)
//	       Logitech, Inc. : Unknown (046d:c52b)
//	       1-1 -> usbip://192.168.1.5:3240/1-2
//	           -> remote bus/dev 001/005
//
// The label is the line between the port header and the import line; it is
// cosmetic, so a format change there loses a name and nothing else.
func (t Tool) Attached() ([]Attached, error) {
	out, err := t.run("port")
	if err != nil {
		// An empty table is not an error, but some builds still exit
		// non-zero for it.  Distinguish by whether anything parsed.
		if out == "" {
			return nil, err
		}
	}

	return parsePortTable(out), nil
}

func parsePortTable(out string) []Attached {
	var list []Attached
	cur := -1
	label := ""
	for _, line := range strings.Split(out, "\n") {
		if m := rePortLine.FindStringSubmatch(line); m != nil {
			cur, _ = strconv.Atoi(m[1])
			label = ""
			continue
		}
		if cur < 0 {
			continue
		}
		if m := reImport.FindStringSubmatch(line); m != nil {
			host := strings.Trim(m[1], "[]")
			list = append(list, Attached{
				Port:   cur,
				BusID:  m[3],
				Server: host,
				Label:  label,
			})
			cur = -1
			continue
		}
		if s := strings.TrimSpace(line); s != "" && !strings.HasPrefix(s, "->") {
			label = s
		}
	}
	return list
}

// AttachedFrom narrows to one server, so a sync from one Moonlight OS box
// can never detach a device imported from a different one.  An empty server
// means every device, which only `uninstall` asks for.
func (t Tool) AttachedFrom(server string) ([]Attached, error) {
	all, err := t.Attached()
	if err != nil && all == nil {
		return nil, err
	}
	if server == "" {
		return all, nil
	}
	var out []Attached
	for _, a := range all {
		if sameHost(a.Server, server) {
			out = append(out, a)
		}
	}
	return out, nil
}

func sameHost(a, b string) bool {
	return strings.EqualFold(strings.Trim(a, "[]"), strings.Trim(b, "[]"))
}

// Sync makes the set of devices imported from server exactly want.
//
// Attach first, then detach.  The other order briefly leaves a device
// attached nowhere, which for a wheel means the force feedback loop drops
// out and the wheel recentres with a bang.
func (t Tool) Sync(server string, port int, want []Device) (SyncResult, error) {
	toolMu.Lock()
	defer toolMu.Unlock()

	res := SyncResult{Attached: []string{}, Detached: []string{}, Failed: []FailedItem{}}

	have, err := t.AttachedFrom(server)
	if err != nil && have == nil {
		return res, err
	}

	haveSet := map[string]Attached{}
	for _, a := range have {
		haveSet[a.BusID] = a
	}
	wantSet := map[string]Device{}
	for _, d := range want {
		if d.BusID == "" {
			continue
		}
		wantSet[d.BusID] = d
	}

	for busid, d := range wantSet {
		if _, ok := haveSet[busid]; ok {
			continue
		}
		if err := t.Attach(server, port, busid); err != nil {
			res.Failed = append(res.Failed, FailedItem{BusID: busid, Error: err.Error()})
			logf("attach %s (%s) failed: %v", busid, d.Label, err)
			continue
		}
		res.Attached = append(res.Attached, busid)
		logf("attached %s %s from %s", busid, d.Label, server)
	}

	// Detach by port, and re-read the table first: attaching above moved
	// the port numbers we read at the top of this function.
	if len(wantSet) != len(haveSet) || len(res.Attached) > 0 {
		if fresh, err := t.AttachedFrom(server); err == nil {
			haveSet = map[string]Attached{}
			for _, a := range fresh {
				haveSet[a.BusID] = a
			}
		}
	}
	for busid, a := range haveSet {
		if _, ok := wantSet[busid]; ok {
			continue
		}
		if err := t.DetachPort(a.Port); err != nil {
			res.Failed = append(res.Failed, FailedItem{BusID: busid, Error: err.Error()})
			logf("detach %s (port %d) failed: %v", busid, a.Port, err)
			continue
		}
		res.Detached = append(res.Detached, busid)
		logf("detached %s from %s", busid, server)
	}

	// A detach on Windows takes a moment to leave the port table.
	if len(res.Detached) > 0 {
		time.Sleep(300 * time.Millisecond)
	}
	res.Current, _ = t.AttachedFrom(server)
	if res.Current == nil {
		res.Current = []Attached{}
	}
	return res, nil
}

func (t Tool) DetachBusID(server, busid string) error {
	toolMu.Lock()
	defer toolMu.Unlock()

	have, err := t.AttachedFrom(server)
	if err != nil && have == nil {
		return err
	}
	for _, a := range have {
		if a.BusID == busid {
			return t.DetachPort(a.Port)
		}
	}
	return fmt.Errorf("%s is not attached", busid)
}

func (t Tool) DetachAll(server string) ([]string, error) {
	toolMu.Lock()
	defer toolMu.Unlock()

	have, err := t.AttachedFrom(server)
	if err != nil && have == nil {
		return nil, err
	}
	done := []string{}
	for _, a := range have {
		if err := t.DetachPort(a.Port); err != nil {
			logf("detach port %d failed: %v", a.Port, err)
			continue
		}
		done = append(done, a.BusID)
	}
	return done, nil
}

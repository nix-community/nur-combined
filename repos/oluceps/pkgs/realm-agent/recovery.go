package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"golang.org/x/sys/unix"
)

type savedState struct {
	Cgroup string `json:"cgroup"`
	Key    string `json:"key"`
}

func (c *controller) statePath() string {
	return filepath.Join(filepath.Dir(c.workload.Socket), "state.json")
}

func (c *controller) saveState() error {
	path, e := os.Readlink(fmt.Sprintf("/proc/self/fd/%d", c.current.cgroup.Fd()))
	if e != nil {
		return e
	}
	s := savedState{Cgroup: strings.TrimPrefix(path, "/sys/fs/cgroup"), Key: c.current.key}
	f, e := os.CreateTemp(filepath.Dir(c.statePath()), ".state-*")
	if e != nil {
		return e
	}
	defer os.Remove(f.Name())
	if e = json.NewEncoder(f).Encode(s); e != nil {
		f.Close()
		return e
	}
	if e = f.Close(); e != nil {
		return e
	}
	return os.Rename(f.Name(), c.statePath())
}

func (c *controller) recover(ctx context.Context) error {
	f, e := os.Open(c.statePath())
	if os.IsNotExist(e) {
		return nil
	}
	if e != nil {
		return e
	}
	var s savedState
	e = json.NewDecoder(io.LimitReader(f, 8192)).Decode(&s)
	f.Close()
	if e != nil {
		return e
	}
	if s.Cgroup == "/" || !strings.HasPrefix(s.Cgroup, "/") || filepath.Clean(s.Cgroup) != s.Cgroup {
		return errors.New("invalid saved cgroup")
	}
	cg, e := os.Open("/sys/fs/cgroup" + s.Cgroup)
	if os.IsNotExist(e) {
		return os.Remove(c.statePath())
	}
	if e != nil {
		return e
	}
	defer cg.Close()
	fd, e := unix.Openat(int(cg.Fd()), "cgroup.procs", unix.O_RDONLY|unix.O_CLOEXEC, 0)
	if e != nil {
		return e
	}
	procs := os.NewFile(uintptr(fd), "cgroup.procs")
	raw, e := io.ReadAll(io.LimitReader(procs, 1<<20))
	procs.Close()
	if e != nil {
		return e
	}
	for _, pid := range strings.Fields(string(raw)) {
		if _, e := strconv.ParseUint(pid, 10, 32); e != nil {
			continue
		}
		proc, e := os.Open("/proc/" + pid)
		if e != nil {
			continue
		}
		var st unix.Stat_t
		e = unix.Fstat(int(proc.Fd()), &st)
		if e != nil || int(st.Uid) != c.uid {
			proc.Close()
			continue
		}
		group, ns, key, e := processNetwork(proc, c.workload.Unit)
		proc.Close()
		if e != nil {
			continue
		}
		if key != s.Key {
			group.Close()
			ns.Close()
			continue
		}
		i, e := c.start(ctx, group, ns, key)
		if e != nil {
			group.Close()
			ns.Close()
			return e
		}
		c.current = i
		return nil
	}
	return nil // The gate may be between ExecStartPre and ExecStart.
}

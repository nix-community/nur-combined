package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"golang.org/x/sys/unix"
)

func writeGroup(group *os.File, name, value string) error {
	fd, e := unix.Openat(int(group.Fd()), name, unix.O_WRONLY|unix.O_CLOEXEC, 0)
	if e != nil {
		return e
	}
	f := os.NewFile(uintptr(fd), name)
	defer f.Close()
	_, e = f.WriteString(value)
	return e
}

// systemd owns the unit root and starts us in its DelegateSubgroup. Never
// enable controllers or move processes in an arbitrary caller-selected group.
func delegatedWorkerRoot() (*os.File, error) {
	raw, e := os.ReadFile("/proc/self/cgroup")
	if e != nil {
		return nil, e
	}
	path := strings.TrimSpace(strings.TrimPrefix(string(raw), "0::"))
	if !strings.HasPrefix(path, "/") || filepath.Clean(path) != path || filepath.Base(path) != "supervisor" || !strings.HasSuffix(filepath.Dir(path), ".service") {
		return nil, errors.New("serve requires a delegated systemd service with DelegateSubgroup=supervisor")
	}
	root, e := os.Open("/sys/fs/cgroup" + filepath.Dir(path))
	if e != nil {
		return nil, e
	}
	ok := false
	defer func() {
		if !ok {
			root.Close()
		}
	}()
	if e := writeGroup(root, "cgroup.subtree_control", "+cpu +memory +pids"); e != nil {
		return nil, fmt.Errorf("enable delegated worker controllers: %w", e)
	}
	supervisor, e := os.Open("/sys/fs/cgroup" + path)
	if e != nil {
		return nil, e
	}
	defer supervisor.Close()
	// The parent unit budget is the sum of these independent leaf budgets.
	for name, value := range map[string]string{"memory.max": "268435456", "memory.swap.max": "0", "pids.max": "128"} {
		if e := writeGroup(supervisor, name, value); e != nil {
			return nil, e
		}
	}
	ok = true
	return root, nil
}

func workerCgroup(root *os.File, w workload) (*os.File, error) {
	name := "worker-" + w.Name
	if e := unix.Mkdirat(int(root.Fd()), name, 0755); e != nil && !errors.Is(e, unix.EEXIST) {
		return nil, e
	}
	fd, e := unix.Openat(int(root.Fd()), name, unix.O_RDONLY|unix.O_DIRECTORY|unix.O_CLOEXEC|unix.O_NOFOLLOW, 0)
	if e != nil {
		return nil, e
	}
	group := os.NewFile(uintptr(fd), name)
	ok := false
	defer func() {
		if !ok {
			group.Close()
		}
	}()
	if populated(group) {
		return nil, errors.New("previous worker cgroup is still populated")
	}
	for file, value := range map[string]string{
		"memory.max":      strconv.FormatInt(int64(w.WorkerMemoryMiB)*1024*1024, 10),
		"memory.swap.max": "0", "memory.oom.group": "1",
		"pids.max": strconv.Itoa(w.WorkerTasks),
		"cpu.max":  fmt.Sprintf("%d 100000", w.WorkerCPUQuota*1000),
	} {
		if e := writeGroup(group, file, value); e != nil {
			return nil, fmt.Errorf("worker budget %s: %w", file, e)
		}
	}
	ok = true
	return group, nil
}

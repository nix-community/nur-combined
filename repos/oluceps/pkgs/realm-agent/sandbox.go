package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"slices"
	"strconv"
	"strings"

	"golang.org/x/sys/unix"
)

type workerConfiguration struct {
	Workload workload `json:"workload"`
	CABundle string   `json:"caBundle"`
}

func sealedWorkerConfig(w workload, ca string) (*os.File, error) {
	fd, e := unix.MemfdCreate("realm-worker-config", unix.MFD_CLOEXEC|unix.MFD_ALLOW_SEALING)
	if e != nil {
		return nil, e
	}
	f := os.NewFile(uintptr(fd), "worker-config")
	defer f.Close()
	if e := json.NewEncoder(f).Encode(workerConfiguration{w, ca}); e != nil {
		return nil, e
	}
	if _, e := unix.FcntlInt(f.Fd(), unix.F_ADD_SEALS, unix.F_SEAL_WRITE|unix.F_SEAL_GROW|unix.F_SEAL_SHRINK|unix.F_SEAL_SEAL); e != nil {
		return nil, e
	}
	// Give the bootstrap and worker a read-only, seekable descriptor.
	readFD, e := unix.Open(fmt.Sprintf("/proc/self/fd/%d", fd), unix.O_RDONLY|unix.O_CLOEXEC, 0)
	if e != nil {
		return nil, e
	}
	return os.NewFile(uintptr(readFD), "worker-config"), nil
}

func workerSocketDirectories(w workload) ([]string, error) {
	var directories []string
	sockets := []string{w.InternetSocket}
	for _, r := range w.Routes {
		sockets = append(sockets, r.Socket)
	}
	for _, socket := range sockets {
		if socket == "" {
			continue
		}
		dir := filepath.Dir(socket)
		// Expose a socket-specific directory, never an entire host runtime tree.
		if dir == "/" || dir == "/run" || dir == "/var" || dir == "/var/run" || dir == "/tmp" || dir == "/etc" || dir == "/nix" || strings.HasPrefix(dir, "/nix/") || dir == "/proc" || strings.HasPrefix(dir, "/proc/") || dir == "/sys" || strings.HasPrefix(dir, "/sys/") || dir == "/dev" || strings.HasPrefix(dir, "/dev/") || dir == "/run/realm-agent" || strings.HasPrefix(dir, "/run/realm-agent/") {
			return nil, fmt.Errorf("egress socket needs a dedicated directory: %s", socket)
		}
		directories = append(directories, dir)
	}
	slices.Sort(directories)
	return slices.Compact(directories), nil
}

// A trusted, short-lived root bootstrap. Only its locked thread changes mount
// namespaces; exec then discards the entire Go runtime. The network namespace
// was already entered by nsenter before this process started.
func sandboxWorker(uid, gid int) (err error) {
	stage := "join worker cgroup"
	defer func() {
		if err != nil {
			err = fmt.Errorf("sandbox %s: %w", stage, err)
		}
	}()
	if os.Geteuid() != 0 || uid <= 0 || gid <= 0 {
		return errors.New("sandbox requires root and unprivileged target IDs")
	}
	group := os.NewFile(8, "worker-cgroup")
	if e := writeGroup(group, "cgroup.procs", strconv.Itoa(os.Getpid())); e != nil {
		group.Close()
		return e
	}
	group.Close() // Never pass a writable cgroup handle to the worker.
	stage = "read sealed configuration"
	config := os.NewFile(6, "worker-config")
	defer config.Close()
	var wc workerConfiguration
	if e := json.NewDecoder(io.LimitReader(config, 1<<20)).Decode(&wc); e != nil {
		return e
	}
	if e := wc.Workload.validate(); e != nil {
		return e
	}
	if _, e := config.Seek(0, io.SeekStart); e != nil {
		return e
	}
	directories, e := workerSocketDirectories(wc.Workload)
	if e != nil {
		return e
	}
	exe, e := os.Executable()
	if e != nil {
		return e
	}
	if !strings.HasPrefix(exe, "/nix/store/") {
		return errors.New("sandbox executable must be in the immutable Nix store")
	}
	stage = "prepare minimal root"
	// The host controller deliberately uses UMask=0077. The new root contains
	// only public paths; its directory ancestors must remain traversable after
	// dropping to the worker UID. Never inherit the controller's private mask.
	unix.Umask(0022)
	root := filepath.Join(filepath.Dir(wc.Workload.Socket), "root")
	if e := os.Mkdir(root, 0755); e != nil && !os.IsExist(e) {
		return e
	}
	var st unix.Stat_t
	if e := unix.Lstat(root, &st); e != nil {
		return e
	}
	if st.Mode&unix.S_IFMT != unix.S_IFDIR || st.Uid != 0 || st.Mode&0022 != 0 {
		return errors.New("unsafe worker sandbox directory")
	}
	runtime.LockOSThread()
	if e := unix.Unshare(unix.CLONE_NEWNS); e != nil {
		return e
	}
	if e := unix.Mount("", "/", "", unix.MS_REC|unix.MS_PRIVATE, ""); e != nil {
		return e
	}
	if e := unix.Mount("tmpfs", root, "tmpfs", unix.MS_NOSUID|unix.MS_NODEV, "mode=0755,size=4M,nr_inodes=1024"); e != nil {
		return e
	}
	bind := func(src, dst string, directory bool) error {
		// Pin sources without traversing symlinks supplied by a workload. Binding
		// the directory (not a socket inode) allows legitimate socket replacement.
		flags := unix.O_PATH | unix.O_CLOEXEC
		if directory {
			flags |= unix.O_DIRECTORY
		}
		fd, e := unix.Openat2(unix.AT_FDCWD, src, &unix.OpenHow{Flags: uint64(flags), Resolve: unix.RESOLVE_NO_SYMLINKS | unix.RESOLVE_NO_MAGICLINKS})
		if e != nil {
			return e
		}
		defer unix.Close(fd)
		target := filepath.Join(root, dst)
		if e := os.MkdirAll(filepath.Dir(target), 0755); e != nil {
			return e
		}
		if directory {
			e = os.MkdirAll(target, 0755)
		} else {
			f, err := os.OpenFile(target, os.O_CREATE|os.O_RDONLY, 0444)
			e = err
			if f != nil {
				f.Close()
			}
		}
		if e != nil {
			return e
		}
		if e := unix.Mount(fmt.Sprintf("/proc/self/fd/%d", fd), target, "", unix.MS_BIND|unix.MS_REC, ""); e != nil {
			return e
		}
		return unix.MountSetattr(unix.AT_FDCWD, target, unix.AT_RECURSIVE, &unix.MountAttr{Attr_set: unix.MOUNT_ATTR_RDONLY | unix.MOUNT_ATTR_NOSUID | unix.MOUNT_ATTR_NODEV})
	}
	stage = "bind declared paths"
	if e := bind("/nix/store", "/nix/store", true); e != nil {
		return e
	}
	ca, e := filepath.EvalSymlinks(wc.CABundle)
	if e != nil {
		return e
	}
	if e := bind(ca, "/etc/ssl/certs/ca-certificates.crt", false); e != nil {
		return e
	}
	for _, dir := range directories {
		if e := bind(dir, dir, true); e != nil {
			return fmt.Errorf("mount egress %s: %w", dir, e)
		}
	}
	if e := os.Mkdir(filepath.Join(root, ".oldroot"), 0700); e != nil {
		return e
	}
	if e := unix.Chdir(root); e != nil {
		return e
	}
	stage = "pivot minimal root"
	if e := unix.PivotRoot(".", ".oldroot"); e != nil {
		return e
	}
	if e := unix.Chdir("/"); e != nil {
		return e
	}
	if e := unix.Unmount("/.oldroot", unix.MNT_DETACH); e != nil {
		return e
	}
	if e := os.Remove("/.oldroot"); e != nil {
		return e
	}
	if e := unix.Mount("", "/", "", unix.MS_REMOUNT|unix.MS_RDONLY|unix.MS_NOSUID|unix.MS_NODEV, ""); e != nil {
		return e
	}
	stage = "drop worker credentials"
	if e := unix.Setgroups([]int{}); e != nil {
		return e
	}
	if e := unix.Setgid(gid); e != nil {
		return e
	}
	if e := unix.Setuid(uid); e != nil {
		return e
	}
	var caps [2]unix.CapUserData
	if e := unix.Capset(&unix.CapUserHeader{Version: unix.LINUX_CAPABILITY_VERSION_3}, &caps[0]); e != nil {
		return e
	}
	if e := unix.Prctl(unix.PR_CAP_AMBIENT, unix.PR_CAP_AMBIENT_CLEAR_ALL, 0, 0, 0); e != nil {
		return e
	}
	if e := unix.Prctl(unix.PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0); e != nil {
		return e
	}
	// Close the namespace FD too: the worker needs only the read-only map,
	// readiness channel, sealed config, and parent-liveness pipe (FDs 4..7).
	unix.Close(3)
	stage = "exec unprivileged worker"
	return unix.Exec(exe, []string{exe, "worker"}, []string{"GOMAXPROCS=2", "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt", "SSL_CERT_DIR=/nonexistent"})
}

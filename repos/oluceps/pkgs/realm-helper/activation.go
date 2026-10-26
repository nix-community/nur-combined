package main

import (
	"errors"
	"os"
	"strconv"
	"strings"
)

// activatedSocket is one listener passed by systemd socket activation.
//
// Units set FileDescriptorName=, so the name identifies the socket instead of
// relying on descriptor order. Everything here is inherited from the manager:
// the helper never binds a privileged port itself.
type activatedSocket struct {
	name string
	file *os.File
}

// activatedSockets returns the descriptors systemd passed to this process.
func activatedSockets() ([]activatedSocket, error) {
	count, _ := strconv.Atoi(os.Getenv("LISTEN_FDS"))
	if count <= 0 || os.Getenv("LISTEN_PID") != strconv.Itoa(os.Getpid()) {
		return nil, errors.New("not started by systemd socket activation")
	}

	names := strings.Split(os.Getenv("LISTEN_FDNAMES"), ":")
	// Clear the variables so an exec'd application never inherits stale state.
	for _, name := range []string{"LISTEN_PID", "LISTEN_FDS", "LISTEN_FDNAMES"} {
		os.Unsetenv(name)
	}

	sockets := make([]activatedSocket, 0, count)
	for i := 0; i < count; i++ {
		name := "fd" + strconv.Itoa(i)
		if i < len(names) && names[i] != "" {
			name = names[i]
		}
		sockets = append(sockets, activatedSocket{
			name: name,
			file: os.NewFile(uintptr(3+i), name),
		})
	}
	return sockets, nil
}

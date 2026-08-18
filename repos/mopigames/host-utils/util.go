package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Version is stamped by build.sh; the default is what a plain `go build` gets.
var Version = "dev"

var verbose = false

func logf(format string, args ...any) {
	log.Printf(format, args...)
}

func vlogf(format string, args ...any) {
	if verbose {
		log.Printf(format, args...)
	}
}

// run executes a command and folds its output into the error, because the
// interesting part of "exit status 1" is always the part that got printed.
func run(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	hideWindow(cmd)
	out, err := cmd.CombinedOutput()
	if err != nil {
		text := strings.TrimSpace(string(out))
		if text == "" {
			return err
		}
		return fmt.Errorf("%s: %s", err, firstLine(text))
	}
	vlogf("ran %s %s", name, strings.Join(args, " "))
	return nil
}

func output(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	hideWindow(cmd)
	out, err := cmd.CombinedOutput()
	return strings.TrimSpace(string(out)), err
}

func die(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "mlos-host-utils: "+format+"\n", args...)
	if wizardMode {
		// Double-clicked, so stderr is a window that is about to close.
		pause("\nPress Enter to close this window.")
	}
	os.Exit(1)
}

func exePath() string {
	p, err := os.Executable()
	if err != nil {
		return os.Args[0]
	}
	return p
}

// installBinary copies this executable somewhere it will still be at the
// next boot.
//
// Without this the service points at wherever the binary happened to be run
// from -- a Downloads folder, a USB stick, a build directory -- and keeps
// pointing there forever.  It works until the folder is tidied up, and then
// the agent silently stops coming back after a reboot, which is exactly the
// failure nobody attributes to the right cause.
//
// A binary a package manager put there is the one case where copying is the
// wrong answer, and it is not a rare one: pacman, nix and winget all install
// to a location that is already permanent, and all three own the file.
// Copying it to our own directory would give the machine two binaries, with
// the service pointing at the copy -- so `pacman -Syu` or `winget upgrade`
// would update a file nothing runs, and the agent would sit at the old
// version forever with nothing to suggest why.
func installBinary() (string, []string, error) {
	src := exePath()

	if isPackagedLocation(src) {
		return src, []string{"already installed at " + src + ", leaving it to the package manager"}, nil
	}

	target := installedExePath()

	if a, err := os.Stat(src); err == nil {
		if b, err := os.Stat(target); err == nil && os.SameFile(a, b) {
			return target, nil, nil // already the installed copy
		}
	}

	if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
		return "", nil, err
	}
	data, err := os.ReadFile(src)
	if err != nil {
		return "", nil, err
	}
	tmp := target + ".new"
	if err := os.WriteFile(tmp, data, 0o755); err != nil {
		return "", nil, err
	}

	// A running executable cannot be overwritten in place -- Linux returns
	// ETXTBSY, Windows refuses to delete it -- but both allow renaming it
	// out of the way, which is how an agent upgrades itself while running.
	if _, err := os.Stat(target); err == nil {
		os.Remove(target + ".old")
		if err := os.Rename(target, target+".old"); err != nil {
			os.Remove(tmp)
			return "", nil, fmt.Errorf("could not replace %s: %w", target, err)
		}
	}
	if err := os.Rename(tmp, target); err != nil {
		os.Remove(tmp)
		return "", nil, err
	}
	// Fails harmlessly while the old one is still running; the next
	// install clears it.
	os.Remove(target + ".old")

	return target, []string{"installed to " + target}, nil
}

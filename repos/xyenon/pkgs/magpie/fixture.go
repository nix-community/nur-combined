// This template is injected into upstream testenv during checks, where test packages
// can share fixture clocks without altering the installed application's writes or caches.
package testenv

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"
)

// NixTouchDir makes fixture installs distinguishable even within one filesystem tick.
// Discovery caches otherwise miss installs and overwrites whose parent mtime did not change.
// An optional baseline preserves the directory clock observed before the install.
func NixTouchDir(path string, baseline ...time.Time) error {
	current, err := os.Stat(path)
	if err != nil {
		return err
	}
	before := current.ModTime()
	for _, prior := range baseline {
		if prior.After(before) {
			before = prior
		}
	}
	stamp := time.Now()
	if !stamp.After(before) {
		stamp = before.Add(time.Nanosecond)
	}
	for _, step := range []time.Duration{0, time.Second} {
		now := stamp.Add(step)
		if err := os.Chtimes(path, now, now); err != nil {
			return err
		}
		after, err := os.Stat(path)
		if err != nil {
			return err
		}
		if after.ModTime().After(before) {
			return nil
		}
	}
	return fmt.Errorf("fixture directory timestamp did not change: %s", path)
}

// NixWriteFixture preserves installer errors and advances its parent clock only on success.
// Capture the old clock first: the write can replace a previously advanced directory mtime
// with a coarse kernel timestamp, hiding the change from discovery's cached snapshot.
func NixWriteFixture(path string, write func() error) error {
	dir := filepath.Dir(path)
	var before time.Time
	if fi, err := os.Stat(dir); err == nil {
		before = fi.ModTime()
	}
	if err := write(); err != nil {
		return err
	}
	return NixTouchDir(dir, before)
}

// NixWriteFile is WriteFile for parameterized test fixtures, without changing the file's mtime.
// Only the parent clock needs adjustment; tests may deliberately compare or restore file mtimes.
func NixWriteFile(path string, data []byte, mode os.FileMode) error {
	return NixWriteFixture(path, func() error { return os.WriteFile(path, data, mode) })
}

// NixSave calibrates real local edits used by sync tests, leaving no-ops and errors intact.
// Kernel-assigned mtimes can lag the wall clock used by backup.Created by several milliseconds.
// Explicit time overrides after Save remain authoritative; internal sync restores are not wrapped.
func NixSave(t testing.TB, path string, save func() error) error {
	t.Helper()
	before, _ := os.Stat(path)
	data, readErr := os.ReadFile(path)
	start := time.Now()
	if err := save(); err != nil {
		return err
	}
	after, err := os.Stat(path)
	if err != nil {
		t.Fatal(err)
	}
	if before != nil && os.SameFile(before, after) && before.ModTime().Equal(after.ModTime()) && before.Size() == after.Size() && readErr == nil {
		if current, err := os.ReadFile(path); err == nil && bytes.Equal(data, current) {
			return nil
		}
	}
	for !after.ModTime().After(start) {
		if time.Since(start) >= time.Second {
			t.Fatalf("fixture file timestamp did not advance past its write start: %s", path)
		}
		stamp := time.Now()
		if err := os.Chtimes(path, stamp, stamp); err != nil {
			t.Fatal(err)
		}
		after, err = os.Stat(path)
		if err != nil {
			t.Fatal(err)
		}
		if !after.ModTime().After(start) {
			time.Sleep(time.Millisecond)
		}
	}
	return nil
}

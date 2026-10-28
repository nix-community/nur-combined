// Autostart must use the public Nix launcher to receive its GTK/Bun environment.
// These tests cover store-path migration while preserving user choices and custom entries.
package autostart

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestNixAutostartLauncher(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	t.Setenv("APPIMAGE", "")
	t.Setenv("PATH", t.TempDir())
	if err := Refresh(); err != nil || Enabled() != Off {
		t.Fatalf("refresh enabled missing entry: %v", err)
	}
	if err := Set(true); err != nil {
		t.Fatal(err)
	}
	check := func() {
		t.Helper()
		body, err := os.ReadFile(record())
		if err != nil {
			t.Fatal(err)
		}
		if !strings.Contains(string(body), "\nExec=\"@magpie@\" tray\n") || strings.Contains(string(body), ".magpie-wrapped") {
			t.Fatalf("incorrect autostart launcher:\n%s", body)
		}
	}
	check()
	old := "[Desktop Entry]\nExec=\"/nix/store/old-magpie/bin/.magpie-wrapped\" tray\n"
	for _, disabled := range []string{"", "Hidden=true\n", "X-GNOME-Autostart-enabled=false\n"} {
		if err := os.WriteFile(record(), []byte(old+disabled), 0o644); err != nil {
			t.Fatal(err)
		}
		if err := Refresh(); err != nil {
			t.Fatal(err)
		}
		check()
		want := strings.Replace(old, "/nix/store/old-magpie/bin/.magpie-wrapped", "@magpie@", 1) + disabled
		if body, err := os.ReadFile(record()); err != nil || string(body) != want {
			t.Fatalf("refresh changed other fields: %s, %v", body, err)
		}
	}
	if err := Set(false); err != nil {
		t.Fatal(err)
	}
	if err := Refresh(); err != nil || Enabled() != Off {
		t.Fatalf("refresh re-enabled removed entry: %v", err)
	}
}

func TestNixAutostartPreservesEntry(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	t.Setenv("APPIMAGE", "")
	t.Setenv("PATH", t.TempDir())
	if err := Set(true); err != nil {
		t.Fatal(err)
	}
	const suffix = "\nComment=custom entry\nX-GNOME-Autostart-Delay=15\n"
	for _, exe := range []string{
		"\"/nix/store/old-magpie/bin/.magpie-wrapped\" tray",
		"/nix/store/old-magpie/bin/magpie tray",
		"\"@magpie@\" tray",
		"\"/opt/my apps/magpie.AppImage\" tray",
		"magpie tray",
		"\"/nix/store/old-magpie/bin/magpie\" tray --custom",
	} {
		old := "[Desktop Entry]\nExec=" + exe + suffix
		if err := os.WriteFile(record(), []byte(old), 0o644); err != nil {
			t.Fatal(err)
		}
		want := old
		if exe == "\"/nix/store/old-magpie/bin/.magpie-wrapped\" tray" || exe == "/nix/store/old-magpie/bin/magpie tray" {
			want = "[Desktop Entry]\nExec=\"@magpie@\" tray" + suffix
		}
		for range 2 {
			if err := Refresh(); err != nil {
				t.Fatal(err)
			}
			if body, err := os.ReadFile(record()); err != nil || string(body) != want {
				t.Fatalf("refresh for %q: %q, want %q (%v)", exe, body, want, err)
			}
		}
	}
}

func TestNixAutostartProfileLauncher(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	t.Setenv("APPIMAGE", "")
	bin := filepath.Join(t.TempDir(), "profile bin")
	if err := os.MkdirAll(bin, 0o755); err != nil {
		t.Fatal(err)
	}
	target := filepath.Join(t.TempDir(), "magpie")
	if err := os.WriteFile(target, []byte("#!/bin/sh\n"), 0o755); err != nil {
		t.Fatal(err)
	}
	launcher := filepath.Join(bin, "magpie")
	if err := os.Symlink(target, launcher); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", bin)
	if err := Set(true); err != nil {
		t.Fatal(err)
	}
	want := "Exec=\"" + launcher + "\" tray\n"
	body, err := os.ReadFile(record())
	if err != nil || !strings.Contains(string(body), want) {
		t.Fatalf("profile entry: %s, %v", body, err)
	}
	if err := Refresh(); err != nil {
		t.Fatal(err)
	}
	if after, err := os.ReadFile(record()); err != nil || string(after) != string(body) {
		t.Fatalf("changed profile entry: %s, %v", after, err)
	}
	for _, exe := range []string{"magpie", ".magpie-wrapped"} {
		old := "[Desktop Entry]\nExec=/nix/store/old/bin/" + exe + " tray\nHidden=true\n"
		if err := os.WriteFile(record(), []byte(old), 0o644); err != nil {
			t.Fatal(err)
		}
		if err := Refresh(); err != nil {
			t.Fatal(err)
		}
		if body, err := os.ReadFile(record()); err != nil || string(body) != "[Desktop Entry]\n"+want+"Hidden=true\n" {
			t.Fatalf("migrated profile entry: %s, %v", body, err)
		}
	}
}

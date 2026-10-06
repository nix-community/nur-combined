package autostart

import (
	"os"
	"strings"
	"testing"
)

func TestNixAutostartLauncher(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	t.Setenv("APPIMAGE", "")
	if err := Refresh(); err != nil || Enabled() {
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
		if disabled == "" {
			check()
		} else if body, err := os.ReadFile(record()); err != nil || string(body) != old+disabled {
			t.Fatalf("refresh changed disabled entry: %s, %v", body, err)
		}
	}
	if err := Set(false); err != nil {
		t.Fatal(err)
	}
	if err := Refresh(); err != nil || Enabled() {
		t.Fatalf("refresh re-enabled removed entry: %v", err)
	}
}

func TestNixAutostartPreservesEntry(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	t.Setenv("APPIMAGE", "")
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

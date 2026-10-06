package gui

import (
	"os"
	"path/filepath"
	"testing"
)

func TestNixSchemeCleanup(t *testing.T) {
	t.Setenv("FLATPAK_ID", "")
	for _, xdg := range []bool{true, false} {
		home := t.TempDir()
		t.Setenv("HOME", home)
		data := filepath.Join(home, ".local", "share")
		t.Setenv("XDG_DATA_HOME", "")
		if xdg {
			data = t.TempDir()
			t.Setenv("XDG_DATA_HOME", data)
		}
		t.Setenv("PATH", t.TempDir())
		path := filepath.Join(data, "applications", "magpie.desktop")
		if err := registerScheme(); err != nil {
			t.Fatal(err)
		}
		if _, err := os.Stat(filepath.Dir(path)); !os.IsNotExist(err) {
			t.Fatalf("created applications directory: %v", err)
		}
		if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
			t.Fatal(err)
		}
		for _, exe := range []string{"/nix/store/old-magpie/bin/.magpie-wrapped", "magpie", "/nix/store/current-magpie/bin/magpie", "/opt/bin/.magpie-wrapped"} {
			old := "[Desktop Entry]\nExec=" + exe + " %u\nMimeType=x-scheme-handler/magpie;\n"
			if err := os.WriteFile(path, []byte(old), 0o644); err != nil {
				t.Fatal(err)
			}
			if err := registerScheme(); err != nil {
				t.Fatal(err)
			}
			body, err := os.ReadFile(path)
			if exe == "/nix/store/old-magpie/bin/.magpie-wrapped" {
				if !os.IsNotExist(err) {
					t.Fatalf("old entry not removed: %v", err)
				}
				if err := registerScheme(); err != nil {
					t.Fatal(err)
				}
				if _, err := os.Stat(path); !os.IsNotExist(err) {
					t.Fatalf("recreated entry: %v", err)
				}
			} else if err != nil || string(body) != old {
				t.Fatalf("modified custom entry: %s, %v", body, err)
			}
		}
	}
}

func TestNixSchemeFlatpak(t *testing.T) {
	t.Setenv("FLATPAK_ID", "ai.usemagpie.Magpie")
	data := t.TempDir()
	t.Setenv("XDG_DATA_HOME", data)
	path := filepath.Join(data, "applications", "magpie.desktop")
	if err := registerScheme(); err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Dir(path)); !os.IsNotExist(err) {
		t.Fatalf("created applications directory: %v", err)
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	const old = "[Desktop Entry]\nExec=/nix/store/old-magpie/bin/.magpie-wrapped %u\nMimeType=x-scheme-handler/magpie;\n"
	if err := os.WriteFile(path, []byte(old), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := registerScheme(); err != nil {
		t.Fatal(err)
	}
	if body, err := os.ReadFile(path); err != nil || string(body) != old {
		t.Fatalf("modified Flatpak entry: %s, %v", body, err)
	}
}

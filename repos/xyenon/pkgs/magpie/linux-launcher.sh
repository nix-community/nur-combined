#!/usr/bin/env bash

set -euo pipefail

launcher=$1

replace_function() {
	local file=$1 signature=$2 body=$3
	local pattern="func $signature { \$\$\$BODY }"
	body=${body//@magpie@/$launcher}
	if ! ast-grep run --lang go --pattern "$pattern" --files-with-matches "$file"; then
		echo "Missing Go function in $file: $signature" >&2
		return 1
	fi
	ast-grep run --lang go --pattern "$pattern" \
		--rewrite "func $signature { $body }" --update-all "$file"
}

# Nix supplies the desktop entry; remove only legacy entries bypassing its wrapper.
replace_function internal/gui/scheme_linux.go 'registerScheme() error' '
	if os.Getenv("FLATPAK_ID") != "" {
		return nil
	}
	data := appdir.Getenv("XDG_DATA_HOME")
	if data == "" {
		home, _ := os.UserHomeDir()
		data = filepath.Join(home, ".local", "share")
	}
	path := filepath.Join(data, "applications", "magpie.desktop")
	old, err := os.ReadFile(path)
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		return err
	}
	if strings.Contains(string(old), "MimeType=x-scheme-handler/magpie;") {
		for _, line := range strings.Split(string(old), "\n") {
			if strings.HasPrefix(line, "Exec=/nix/store/") && strings.HasSuffix(line, "/bin/.magpie-wrapped %u") {
				return os.Remove(path)
			}
		}
	}
	return nil
'

# AppImage takes precedence; Linux Nix launches must use the outer wrapper.
replace_function internal/autostart/autostart.go 'self() (string, error)' '
	if p := os.Getenv("APPIMAGE"); p != "" {
		return p, nil
	}
	return "@magpie@", nil
'

replace_function internal/autostart/autostart_other.go 'refresh() error' '
	body, err := os.ReadFile(record())
	if os.IsNotExist(err) {
		return nil
	}
	if err != nil {
		return err
	}
	lines := strings.Split(string(body), "\n")
	for _, line := range lines {
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		key, value = strings.TrimSpace(key), strings.TrimSpace(value)
		if key == "Hidden" && value == "true" || key == "X-GNOME-Autostart-enabled" && value == "false" {
			return nil
		}
	}
	for i, line := range lines {
		key, value, ok := strings.Cut(line, "=")
		if !ok || strings.TrimSpace(key) != "Exec" {
			continue
		}
		value = strings.TrimSpace(value)
		if !strings.HasSuffix(value, " " + Arg) {
			return nil
		}
		exe := strings.Trim(strings.TrimSuffix(value, " " + Arg), "\"")
		if !strings.HasPrefix(exe, "/nix/store/") ||
			!strings.HasSuffix(exe, "/bin/.magpie-wrapped") && !strings.HasSuffix(exe, "/bin/magpie") {
			return nil
		}
		replacement := "Exec=\"@magpie@\" " + Arg
		if line == replacement {
			return nil
		}
		lines[i] = replacement
		return os.WriteFile(record(), []byte(strings.Join(lines, "\n")), 0o644)
	}
	return nil
'

if [ -f internal/gui/scheme_linux_test.go ]; then
	# Nix replaces native registration, but upstream Flatpak cases still apply.
	# shellcheck disable=SC2016
	pattern='t.Run(tc.name, func(t *testing.T) { $$$BODY })'
	ast-grep run --lang go --pattern "$pattern" --files-with-matches internal/gui/scheme_linux_test.go
	# shellcheck disable=SC2016
	ast-grep run --lang go --pattern "$pattern" --rewrite '
		t.Run(tc.name, func(t *testing.T) {
			if !tc.flatpak {
				t.Skip("Nix registration is covered by TestNixSchemeCleanup")
			}
			$$$BODY
		})' --update-all internal/gui/scheme_linux_test.go
	gofmt -w internal/gui/scheme_linux_test.go
fi

goimports -w internal/gui/scheme_linux.go \
	internal/autostart/autostart.go internal/autostart/autostart_other.go

#!/usr/bin/env bash
# ast-grep metavariables must remain literal.
# shellcheck disable=SC2016

set -euo pipefail

platform=$1
launcher=$2
bun=$3

selfpath=github.com/yetone/magpie/internal/selfpath

# Upstream moves and renames files often, so every pattern finds its code
# wherever it is: the whole tree is scanned, not a list of files. Vendored and
# upstream Go, and tests, are left as they are.
globs=(
	--globs '!third_party/**'
	--globs '!vendor/**'
	--globs '!**/*_test.go'
)

rewrite() {
	local pattern=$1 to=$2
	if ! ast-grep run --lang go --pattern "$pattern" \
		--rewrite "$to" --update-all . "${globs[@]}"; then
		echo "warning: no $pattern found" >&2
	fi
}

replace_function() {
	local signature=$1 body=$2
	rewrite "func $signature { \$\$\$BODY }" "func $signature { $body }"
}

go_files() {
	grep -rl --include='*.go' --exclude='*_test.go' \
		--exclude-dir=third_party --exclude-dir=vendor --exclude-dir=selfpath \
		"$1" . || true
}

if [[ $platform == darwin ]]; then
	# Keep the bundle executable native: an exec wrapper breaks Launch Services tracking.
	# The environment goes into the program itself, so macOS never has a wrapped binary.
	ast-grep run --lang go --pattern 'func main() { $$$BODY }' \
		--rewrite "func main() { os.Setenv(\"MAGPIE_BUN\", \"$bun\"); \$\$\$BODY }" \
		--update-all main.go
	ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
		--rewrite 'import ("os"; $$$IMPORTS)' --update-all main.go
	goimports -w main.go
	exit 0
fi

marker=$(mktemp)

# Nix starts magpie through $out/bin/magpie, whose wrapper sets the environment
# it needs (Bun, GTK, PATH). os.Executable reports the wrapped binary beside it,
# $out/bin/.magpie-wrapped, so every path magpie names or runs itself names the
# launcher instead: selfpath.Program is the magpie on PATH when it is this
# install's (a profile link survives a store update), else this one's
# $out/bin/magpie.
rewrite 'os.Executable()' 'selfpath.Program()'

# A restart into an update, and the restart handover, run the launcher.
rewrite 'update.Executable()' 'update.Program()'

# Two callers need the file that runs, not the launcher: update.Executable is
# what PackagedBy reads to know a package manager installed this magpie, and
# ownMagpie compares the port's holder in /proc/<pid>/exe with it.
ast-grep scan --inline-rules '
id: selfpath-real-exe
language: Go
rule:
  pattern: selfpath.Program()
  inside:
    kind: function_declaration
    has:
      field: name
      regex: "^(Executable|ownMagpie)$"
    stopBy: end
fix: selfpath.Executable()
' --update-all . "${globs[@]}"

# A program kept as a value rather than called: the uninstaller's --data-after.
files=$(go_files '= os\.Executable$')
if [[ -n $files ]]; then
	while IFS= read -r file; do
		sed -i 's/= os\.Executable$/= selfpath.Program/' "$file"
	done <<<"$files"
fi

# The program a link, an agent config (Claude Code's status line, an MCP
# server) or a login item names, and the one ReadCLI reports (cliExe).
replace_function 'Program() (string, error)' 'return selfpath.Program()'
replace_function 'cliProgram() (string, error)' 'return selfpath.Program()'

# The login item keeps the launcher unresolved, so a profile link survives.
replace_function 'self() (string, error)' 'return selfpath.Program()'

# Refresh old Nix paths without enabling disabled entries or changing custom commands.
replace_function 'refresh() error' '
	body, err := os.ReadFile(record())
	if os.IsNotExist(err) { return nil }
	if err != nil { return err }
	lines := strings.Split(string(body), "\n")
	for i, line := range lines {
		key, value, ok := strings.Cut(line, "=")
		if !ok || strings.TrimSpace(key) != "Exec" { continue }
		value = strings.TrimSpace(value)
		if !strings.HasSuffix(value, " " + Arg) { return nil }
		exe := strings.Trim(strings.TrimSuffix(value, " " + Arg), "\"")
		if !strings.HasPrefix(exe, "/nix/store/") || !strings.HasSuffix(exe, "/bin/.magpie-wrapped") && !strings.HasSuffix(exe, "/bin/magpie") { return nil }
		launcher, err := self()
		if err != nil { return err }
		q := strings.NewReplacer("\\", "\\\\", "\"", "\\\"", "\x60", "\\\x60", "$", "\\$").Replace(launcher)
		replacement := "Exec=\"" + q + "\" " + Arg
		if line == replacement { return nil }
		lines[i] = replacement
		return os.WriteFile(record(), []byte(strings.Join(lines, "\n")), 0o644)
	}
	return nil
'

# Nix supplies the desktop entry; upstream still cleans up legacy entries.
replace_function 'registerScheme() error' 'return nil'

# The launcher itself, a package of its own: every place that names or runs
# magpie uses selfpath.Program, and only the two exceptions above use the file
# that runs.
mkdir -p internal/selfpath
cat >internal/selfpath/selfpath.go <<EOF
// Package selfpath names the program that starts this magpie: Nix's wrapper
// beside the binary os.Executable reports.
package selfpath

import (
	"os"
	"os/exec"
	"path/filepath"
)

// Program is the launcher to run or name for this magpie: the magpie on PATH
// when it is this install's, else the installed launcher. An AppImage is itself.
func Program() (string, error) {
	if a := os.Getenv("APPIMAGE"); a != "" {
		return a, nil
	}
	if p, err := exec.LookPath("magpie"); err == nil {
		if abs, err := filepath.Abs(p); err == nil {
			if r, err := filepath.EvalSymlinks(abs); err == nil && r == "$launcher" {
				return abs, nil
			}
		}
	}
	return "$launcher", nil
}

// Executable is the running binary, symlinks resolved.
func Executable() (string, error) {
	exe, err := os.Executable()
	if err != nil {
		return "", err
	}
	return filepath.EvalSymlinks(exe)
}
EOF

# Every file that now names selfpath gets its import, wherever it is.
files=$(go_files 'selfpath\.')
if [[ -n $files ]]; then
	while IFS= read -r file; do
		grep -q "$selfpath" "$file" && continue
		ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
			--rewrite "import (\$\$\$IMPORTS; \"$selfpath\")" --update-all "$file" ||
			sed -i "0,/^package .*/s//&\n\nimport \"$selfpath\"/" "$file"
	done <<<"$files"
fi

# Only what this patch changed is formatted; upstream files stay as they are.
find . \( -path ./vendor -o -path ./third_party \) -prune -o \
	-name '*.go' -newer "$marker" -exec goimports -w {} +
rm -f "$marker"

#!/usr/bin/env bash
# ast-grep metavariables must remain literal.
# shellcheck disable=SC2016

set -euo pipefail

platform=$1
bun=$2

appdir=github.com/yetone/magpie/internal/appdir

# Follow call sites across files, leaving vendored code, tests and other platforms alone.
globs=(
	--globs '!third_party/**'
	--globs '!vendor/**'
	--globs '!**/*_test.go'
	--globs '!**/*_{android,darwin,windows}.go'
	--globs '!**/*_{android,darwin,windows}_*.go'
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
		--exclude-dir=third_party --exclude-dir=vendor --exclude-dir=appdir \
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
trap 'rm -f "$marker"' EXIT

# Only substitute the launcher in code that names or starts magpie. Leave
# appdir's own discovery and code identifying or inspecting the running file.
ast-grep scan --inline-rules '
id: nix-self-launcher
language: Go
rule:
  pattern: os.Executable()
  not:
    inside:
      stopBy: end
      all:
        - any:
            - kind: function_declaration
            - kind: method_declaration
            - kind: func_literal
        - any:
            - has:
                field: name
                regex: "^(Executable|ownMagpie|keepWebData|appIconFor|sourceKey|wslFirewallCommand|cpuProfile|heapProfile|goroutineDump)$"
            - has:
                pattern: appdir.Launcher()
                stopBy: end
fix: appdir.LaunchProgram(os.Executable)
' --update-all . "${globs[@]}" --globs '!internal/appdir/**'

# Shared executable lookups also serve update and cleanup code. Only change
# their use in functions that launch, hand over to, or follow a successor.
ast-grep scan --inline-rules '
id: nix-restart-launcher
language: Go
rule:
  pattern: $RESOLVE()
  inside:
    stopBy: end
    all:
      - any:
          - kind: function_declaration
          - kind: method_declaration
          - kind: func_literal
      - any:
          - has:
              stopBy: end
              any:
                - pattern: relaunchBinary($EXE, $$$ARGS)
                - pattern: beginHandover($BUNDLE, $EXE, $$$ARGS)
                - pattern: update.Reexec($EXE, $$$ARGS)
                - pattern: takeOver($EXE)
          - has:
              field: name
              regex: "^(newServeFollow|DataAfterExit)$"
constraints:
  RESOLVE:
    regex: "^(executable|update\\.Executable)$"
fix: appdir.LaunchProgram($RESOLVE)
' --update-all . "${globs[@]}"

# A profile switch can replace the launcher with one of the same size and mtime.
rewrite 'now.Size() != $STARTED.Size() || !now.ModTime().Equal($STARTED.ModTime())' \
	'!os.SameFile(now, $STARTED) || now.Size() != $STARTED.Size() || !now.ModTime().Equal($STARTED.ModTime())'

# Refresh old Nix paths without enabling disabled entries or changing custom commands.
replace_function 'refresh() error' '
	body, err := os.ReadFile(record())
	if os.IsNotExist(err) { return nil }
	if err != nil { return err }
	if !starts(keys(body)) { return nil }
	lines := strings.Split(string(body), "\n")
	i := appdir.NixDesktopExec(lines, Arg)
	if i < 0 { return nil }
	launcher := appdir.Launcher()
	if launcher == "" { return nil }
	q := strings.NewReplacer(`\`, `\\`, `"`, `\"`, "`", "\\`", `$`, `\$`).Replace(launcher)
	replacement := "Exec=\"" + q + "\" " + Arg
	if lines[i] == replacement { return nil }
	lines[i] = replacement
	return writeRecord(strings.Join(lines, "\n"))
'

# The packaged desktop entry wins once a legacy Nix entry stops shadowing it.
# Leave unpackaged builds' registration and user-owned entries alone.
ast-grep scan --inline-rules '
id: nix-retire-scheme-entry
language: Go
rule:
  pattern: $DATA := dataHome()
  inside:
    kind: function_declaration
    stopBy: end
    has:
      pattern: proc.Command("xdg-mime", "default", $$$ARGS)
      stopBy: end
fix: |
  $DATA := dataHome()
  if wrapper := os.Getenv("MAGPIE_EXECUTABLE"); wrapper != "" {
    return appdir.RetireNixDesktopEntry($DATA, wrapper)
  }
' --update-all . "${globs[@]}"

cat >internal/appdir/nix_packaging_linux.go <<'EOF'
package appdir

import (
	"os"
	"path/filepath"
	"strings"
)

// LaunchProgram selects a launcher for code that is about to name or start magpie.
func LaunchProgram(executable func() (string, error)) (string, error) {
	if a := os.Getenv("APPIMAGE"); a != "" {
		return a, nil
	}
	if p := Launcher(); p != "" {
		return p, nil
	}
	return executable()
}

func desktopKey(lines []string, wanted string) int {
	index, inEntry := -1, false
	for i, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "[") {
			inEntry = line == "[Desktop Entry]"
		}
		if key, _, ok := strings.Cut(line, "="); inEntry && ok && strings.TrimSpace(key) == wanted {
			index = i
		}
	}
	return index
}

func desktopValue(line string) string {
	_, value, _ := strings.Cut(line, "=")
	return strings.TrimSpace(value)
}

// NixDesktopExec finds the effective Exec line of an old Nix Magpie entry.
func NixDesktopExec(lines []string, arg string) int {
	index := desktopKey(lines, "Exec")
	if index < 0 {
		return -1
	}
	exe, ok := strings.CutSuffix(desktopValue(lines[index]), " " + arg)
	if !ok {
		return -1
	}
	exe = strings.Trim(exe, `"`)
	storePath, ok := strings.CutPrefix(exe, "/nix/store/")
	if !ok {
		return -1
	}
	pkg, rel, _ := strings.Cut(storePath, "/")
	_, name, _ := strings.Cut(pkg, "-")
	if name != "magpie" && !strings.HasPrefix(name, "magpie-") {
		return -1
	}
	switch rel {
	case "bin/magpie", "bin/.magpie-wrapped", "libexec/magpie/magpie":
		return index
	}
	return -1
}

// RetireNixDesktopEntry removes a legacy entry only if the desktop can see
// the replacement shipped by this package. Other user entries stay in place.
func RetireNixDesktopEntry(data, wrapper string) error {
	const desktop = "magpie.desktop"
	entry := filepath.Join(data, "applications", desktop)
	info, err := os.Lstat(entry)
	if os.IsNotExist(err) || err == nil && !info.Mode().IsRegular() {
		return nil
	}
	if err != nil {
		return err
	}
	body, err := os.ReadFile(entry)
	if err != nil {
		return err
	}
	lines := strings.Split(string(body), "\n")
	if NixDesktopExec(lines, "%u") < 0 && NixDesktopExec(lines, "%U") < 0 {
		return nil
	}
	i := desktopKey(lines, "MimeType")
	if i < 0 || !strings.Contains(";" + desktopValue(lines[i]) + ";", ";x-scheme-handler/magpie;") {
		return nil
	}
	for _, key := range []string{"Hidden", "NoDisplay"} {
		if i := desktopKey(lines, key); i >= 0 && (desktopValue(lines[i]) == "true" || desktopValue(lines[i]) == "1") {
			return nil
		}
	}
	share := filepath.Join(filepath.Dir(wrapper), "..", "share")
	packaged, err := os.Stat(filepath.Join(share, "applications", desktop))
	if err != nil {
		return nil
	}
	dirs := Getenv("XDG_DATA_DIRS")
	if dirs == "" {
		dirs = "/usr/local/share:/usr/share"
	}
	for _, dir := range filepath.SplitList(dirs) {
		// GApps adds the app's own share to its environment even under nix run.
		if !filepath.IsAbs(dir) || filepath.Clean(dir) == share {
			continue
		}
		candidate, err := os.Stat(filepath.Join(dir, "applications", desktop))
		if os.IsNotExist(err) {
			continue
		}
		if err != nil || !os.SameFile(candidate, packaged) {
			return nil
		}
		if err := os.Remove(entry); !os.IsNotExist(err) {
			return err
		}
		break
	}
	return nil
}
EOF

# Give newly patched call sites their import wherever they are in the tree.
files=$(go_files 'appdir\.\(LaunchProgram\|NixDesktopExec\|RetireNixDesktopEntry\)')
if [[ -n $files ]]; then
	while IFS= read -r file; do
		grep -Fq "$appdir" "$file" && continue
		ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
			--rewrite "import (\$\$\$IMPORTS; \"$appdir\")" --update-all "$file" ||
			sed -i "0,/^package .*/s//&\n\nimport \"$appdir\"/" "$file"
	done <<<"$files"
fi

# Only what this patch changed is formatted; upstream files stay as they are.
find . \( -path ./vendor -o -path ./third_party \) -prune -o \
	-name '*.go' -newer "$marker" -exec goimports -w {} +

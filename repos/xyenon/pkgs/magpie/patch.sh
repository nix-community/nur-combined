#!/usr/bin/env bash
# ast-grep metavariables must remain literal.
# shellcheck disable=SC2016

set -euo pipefail

platform=$1
gui=$2
launcher=$3
bun=$4

replace_function() {
	local file=$1 signature=$2 body=$3
	local pattern="func $signature { \$\$\$BODY }"
	ast-grep run --lang go --pattern "$pattern" \
		--rewrite "func $signature { $body }" --update-all "$file"
}

if [[ $gui != true ]]; then
	exit 0
fi

case $platform in
linux)
	# Nix supplies the desktop entry; upstream still cleans up legacy entries.
	replace_function internal/gui/scheme_linux.go 'registerScheme() error' 'return nil'

	# Keep AppImage precedence and use the PATH launcher without resolving symlinks.
	replace_function internal/autostart/autostart.go 'self() (string, error)' "
		if p := os.Getenv(\"APPIMAGE\"); p != \"\" { return p, nil }
		if p, err := exec.LookPath(\"magpie\"); err == nil { return p, nil }
		return \"$launcher\", nil
	"

	# Refresh old Nix paths without enabling disabled entries or changing custom commands.
	replace_function internal/autostart/autostart_other.go 'refresh() error' '
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

	# goimports removes unused imports but needs the new package declared explicitly.
	ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
		--rewrite 'import ("os/exec"; $$$IMPORTS)' --update-all internal/autostart/autostart.go
	goimports -w internal/gui/scheme_linux.go \
		internal/autostart/autostart.go internal/autostart/autostart_other.go
	;;
darwin)
	# Keep the bundle executable native: an exec wrapper breaks Launch Services tracking.
	ast-grep run --lang go --pattern 'func main() { $$$BODY }' \
		--rewrite "func main() { os.Setenv(\"MAGPIE_BUN\", \"$bun\"); \$\$\$BODY }" \
		--update-all main.go
	ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
		--rewrite 'import ("os"; $$$IMPORTS)' --update-all main.go
	goimports -w main.go
	;;
esac

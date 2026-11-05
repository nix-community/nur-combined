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
  # Nix provides the desktop entry; skip upstream's user-level one.
  replace_function internal/gui/scheme_linux.go 'registerScheme() error' 'return nil'

  # Don't resolve the wrapper symlink; look the launcher up on PATH.
  replace_function internal/autostart/autostart.go 'self() (string, error)' "
		if p := os.Getenv(\"APPIMAGE\"); p != \"\" { return p, nil }
		if p, err := exec.LookPath(\"magpie\"); err == nil { return p, nil }
		return \"$launcher\", nil
	"

  # self() now uses os/exec; add the import, then tidy.
  ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
    --rewrite 'import ("os/exec"; $$$IMPORTS)' --update-all internal/autostart/autostart.go
  goimports -w internal/gui/scheme_linux.go internal/autostart/autostart.go
  ;;
darwin)
  # The .app can't be wrapped, so set MAGPIE_BUN in-process.
  ast-grep run --lang go --pattern 'func main() { $$$BODY }' \
    --rewrite "func main() { os.Setenv(\"MAGPIE_BUN\", \"$bun\"); \$\$\$BODY }" \
    --update-all main.go
  ast-grep run --lang go --pattern 'import ($$$IMPORTS)' \
    --rewrite 'import ("os"; $$$IMPORTS)' --update-all main.go
  goimports -w main.go
  ;;
esac

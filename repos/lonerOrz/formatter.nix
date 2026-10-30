{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "nur-fmt";

  runtimeInputs = with pkgs; [
    nixfmt-rfc-style # .nix
    shfmt # .sh
    ruff # .py
    mdformat # .md
    rustfmt # .rs
    stylua # .lua
    prettier # .{html,js,css,yaml,yml,json,toml}
    svgo # .svg
  ];

  text = ''
    set -euo pipefail

    fmt_file() {
      case "$1" in
        *.nix)    nixfmt "$1" ;;
        *.sh)     shfmt -i 2 -ci -bn compat -w "$1" 2>/dev/null || true ;;
        *.py)     ruff format --quiet "$1" ;;
        *.md)     mdformat "$1" ;;
        *.rs)     rustfmt "$1" ;;
        *.lua)    stylua "$1" ;;
        *.html|*.js|*.css|*.yaml|*.yml|*.json|*.toml) prettier --write "$1" 2>/dev/null || true ;;
        *.svg)          svgo --pretty "$1" ;;
        *)        echo "Skipped (unknown): $1" >&2 ;;
      esac
    }

    if [ $# -gt 0 ]; then
      for f in "$@"; do
        [ -f "$f" ] && fmt_file "$f"
      done
    else
      git ls-files | while IFS= read -r f; do
        [ -f "$f" ] && fmt_file "$f"
      done
    fi
  '';
}

{
  writeShellApplication,
  nixfmt,
  shfmt,
  ruff,
  mdformat,
  rustfmt,
  stylua,
  prettier,
  svgo,
}:
writeShellApplication {
  name = "nur-fmt";
  runtimeInputs = [
    nixfmt
    shfmt
    ruff
    mdformat
    rustfmt
    stylua
    prettier
    svgo
  ];
  text = ''
    set -euo pipefail

    total=0
    changed=0
    skipped=0
    failed_count=0
    failed_list=""

    run_fmt() {
      case "$1" in
        *.nix)  nixfmt "$1" ;;
        *.sh)   shfmt -i 2 -ci -bn compat -w "$1" ;;
        *.py)   ruff format --silent "$1" ;;
        *.md)   mdformat "$1" ;;
        *.rs)   rustfmt --quiet "$1" ;;
        *.lua)  stylua "$1" ;;
        *.html|*.js|*.css|*.yaml|*.yml|*.json|*.toml) prettier --write "$1" ;;
        *.svg)  svgo --pretty "$1" ;;
        *)      return 2 ;;
      esac
    }

    handle_file() {
      f="$1"
      [ -f "$f" ] || return 0

      case "$f" in
        *.nix|*.sh|*.py|*.md|*.rs|*.lua|*.html|*.js|*.css|*.yaml|*.yml|*.json|*.toml|*.svg) ;;
        *) skipped=$((skipped + 1)); return 0 ;;
      esac

      total=$((total + 1))
      printf 'fmt: %s\n' "$f"

      before=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1) || true

      if run_fmt "$f" >/dev/null 2>&1; then
        after=$(md5sum "$f" 2>/dev/null | cut -d' ' -f1) || true
        if [ "$before" != "$after" ]; then
          changed=$((changed + 1))
        fi
      else
        failed_count=$((failed_count + 1))
        failed_list="$failed_list$f"$'\n'
      fi
    }

    if [ $# -gt 0 ]; then
      for f in "$@"; do
        handle_file "$f"
      done
    else
      while IFS= read -r -d $'\0' f; do
        handle_file "$f"
      done < <(git ls-files -z)
    fi

    printf '\nnur-fmt: %d formatted, %d changed, %d skipped, %d failed\n' \
      "$total" "$changed" "$skipped" "$failed_count" >&2

    if [ "$failed_count" -gt 0 ]; then
      printf 'nur-fmt: failed files:\n%s' "$failed_list" >&2
      exit 1
    fi
  '';
}

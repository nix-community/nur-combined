{ writeShellScriptBin, weechat-matrix, xdg-utils }: writeShellScriptBin "emxc" ''
  set -eu

  if [[ $# -gt 0 ]]; then
    EXMC="$1"
  else
    echo no args specified >&2
    exit 1
  fi

  if [[ $# -gt 1 ]]; then
    OUT=$(mktemp --tmpdir "emxc.$2.XXXXXXXXXX")
  else
    OUT=$(mktemp --tmpdir emxc.XXXXXXXXXX)
  fi

  ${weechat-matrix}/bin/matrix_decrypt "$EXMC" "$OUT"
  ${xdg-utils}/bin/xdg-open "$OUT" || firefox "file://$OUT"
''

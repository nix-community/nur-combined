{ writeShellScriptBin
, weechat-matrix
, curl
, openMode ? "xdg-open"
}: let
  opener = {
    # TODO: mimeo, and more: https://wiki.archlinux.org/title/Default_applications#Resource_openers
    gio = "gio open";
    xdg-open = "xdg-open";
  }.${openMode} or (throw "unsupported openMode ${openMode}");
in writeShellScriptBin "emxc" ''
  set -eu

  if [[ $# -gt 0 ]]; then
    URL="$1"
  else
    echo no args specified >&2
    exit 1
  fi

  if [[ $# -gt 1 ]]; then
    OUT=$(mktemp --tmpdir --suffix=".$2" emxc.XXXXXXXXXX)
  else
    OUT=$(mktemp --tmpdir emxc.XXXXXXXXXX)
  fi

  if [[ $URL = emxc://* ]]; then
    ${weechat-matrix}/bin/matrix_decrypt "$URL" "$OUT"
  else
    ${curl}/bin/curl -LsSfo "$OUT" "$URL"
  fi
  ${opener} "$OUT"
''

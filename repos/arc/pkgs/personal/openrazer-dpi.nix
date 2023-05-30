{ writeShellScriptBin, xxd }: writeShellScriptBin "openrazer-dpi" ''
  set -eu

  if [[ -z ''${DEVPATH-} ]]; then
    for dev in /sys/bus/hid/drivers/razermouse/*/; do
      if [[ -e $dev/dpi ]]; then
        DEVPATH=''${dev#/sys/}
        break
      fi
    done
  fi

  if [[ -z ''${DEVPATH-} ]]; then
    echo "DEVPATH not provided" >&2
    exit 1
  fi

  DPI_X=$1
  DPI_Y=''${2-$DPI_X}
  printf %04x%04x "$DPI_X" "$DPI_Y" | ${xxd}/bin/xxd -r -p > /sys/$DEVPATH/dpi
''

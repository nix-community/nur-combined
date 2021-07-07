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

  printf %04x $1 | ${xxd}/bin/xxd -r -p > /sys/$DEVPATH/dpi
''

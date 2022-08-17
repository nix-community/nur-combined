PATH=$PATH:@fhs@/bin:@binutils@/bin
if [ $# == 0 ]; then
    echo "No AppImage provided"
    exit 1
fi
if [[ -v REPL ]]; then
    appimage-env
fi

APPIMAGE="$1"; shift
OFFSET=$(LC_ALL=C readelf -h "$APPIMAGE" | awk 'NR==13{e_shoff=$5} NR==18{e_shentsize=$5} NR==19{e_shnum=$5} END{print e_shoff+e_shentsize*e_shnum}')
LOOP=$(udisksctl loop-setup -f "$APPIMAGE" --offset "$OFFSET" | sed 's;[ \.];\n;g' | grep '/dev/loop')
MOUNTPOINT=$(udisksctl mount -b $LOOP | sed 's;[ \.];\n;g' | grep '/media')
if [ ! -z "$MOUNTPOINT" ]; then
  appimage-env "$MOUNTPOINT/AppRun" "$@"
fi
if [ ! -z "$LOOP" ]; then
  while true; do
    if [[ ! "$(udisksctl unmount -b "$LOOP" 2>&1 || true)" =~ "Error" ]]; then
      break
    fi
    sleep 1
  done
  while true; do
    udisksctl loop-delete -b "$LOOP" && break || true
    sleep 1
  done
fi

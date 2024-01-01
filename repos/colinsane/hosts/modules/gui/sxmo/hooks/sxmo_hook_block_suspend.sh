#!/usr/bin/env nix-shell
#!nix-shell -i bash -p procps


wait_item() {
  while $1 > /dev/null 2>&1; do
    waited=1
    sleep 1
  done
}

casting_go2tv() {
  pgrep -f go2tv
}

while [ "$waited" != "0" ]; do
  waited=0
  wait_item casting_go2tv

  # forward to the next block_suspend.sh script (if any).
  # have to handle the case where this script is on PATH, and also when it was called without being on PATH.
  # the implementation here causes us to call ourselves exactly once, at most.
  SXMO_HOOK_BLOCK_SUSPEND_DEPTH=$((${SXMO_HOOK_BLOCK_SUSPEND_DEPTH:-0} + 1))
  echo "recurse counter: $SXMO_HOOK_BLOCK_SUSPEND_DEPTH"

  FWD_COUNT=0
  IFS=:
  for p in $PATH ; do 
    echo "testing: $p/sxmo_hook_block_suspend.sh"
    if $(test -x "$p/sxmo_hook_block_suspend.sh"); then
      FWD_COUNT=$(($FWD_COUNT + 1))
    fi
    if [ "$FWD_COUNT" -eq "$SXMO_HOOK_BLOCK_SUSPEND_DEPTH" ]; then
      echo "forwarding to: $p/sxmo_hook_block_suspend.sh"
      "$p/sxmo_hook_block_suspend.sh"
    fi
  done
done

#!/usr/bin/env nix-shell
#!nix-shell -i bash -p procps

# Basic exponential backoff, this should save some resources if we're blocked by
# the same thing for a while
delay() {
  sleep "$delay_time"
  delay_time="$((delay_time*2))"
  if [ "$delay_time" -gt 45 ]; then
    delay_time=45
  fi
}

wait_item() {
  delay_time=1
  while $1 > /dev/null 2>&1; do
    echo "Blocking suspend for $1"
    waited=1
    delay
  done
}

##################################### below is original, not shared with upstream sxmo_hook_block_suspend.sh

casting_go2tv() {
  pgrep -f go2tv
}

# forward to the next block_suspend.sh script (if any).
# have to handle the case where this script is on PATH, and also when it was called without being on PATH.
# the implementation here causes us to call ourselves exactly once, at most (or twice, if there are duplicate PATH entries)
SXMO_HOOK_BLOCK_SUSPEND_DEPTH=$((${SXMO_HOOK_BLOCK_SUSPEND_DEPTH:-0} + 1))
echo "recurse counter: $SXMO_HOOK_BLOCK_SUSPEND_DEPTH"

block_suspend_next=true
FWD_COUNT=0
IFS=:
for p in $PATH ; do
  echo "testing: $p/sxmo_hook_block_suspend.sh"
  if $(test -x "$p/sxmo_hook_block_suspend.sh"); then
    FWD_COUNT=$(($FWD_COUNT + 1))
  fi
  if [ "$FWD_COUNT" -eq "$SXMO_HOOK_BLOCK_SUSPEND_DEPTH" ]; then
    block_suspend_next="$p/sxmo_hook_block_suspend.sh"
    break
  fi
done

while [ "$waited" != "0" ]; do
  waited=0

  echo "forwarding to: $block_suspend_next"
  SXMO_HOOK_BLOCK_SUSPEND_DEPTH="$SXMO_HOOK_BLOCK_SUSPEND_DEPTH" "$block_suspend_next"

  # wait for my own items last. else, we could wait for go2tv, then wait for internals, and in the meantime go2tv was re-spawned.
  wait_item casting_go2tv
done

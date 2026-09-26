#!/usr/bin/env bash
# Boot the throwaway NixOS guest in ./flake.nix under firecracker and report
# whether sasso installs and works on it. See ../README.md for what it proves
# and when it is worth the minutes.
#
# Needs: Linux with /dev/kvm, root (it makes a tap device and one NAT rule),
# nix with flakes, iproute2, iptables, and a few GB of scratch in /tmp for the
# guest's store overlay. The scratch directory goes away on PASS.
#
# Usage:
#   sudo ./run.sh                          # the published flake
#   sudo SASSO_FLAKE=/path/to/checkout ./run.sh
#   sudo SASSO_FLAKE='git+https://github.com/momiji-rs/sasso?ref=some-branch' ./run.sh
#   sudo KEEP_RUNDIR=1 ./run.sh            # keep the scratch dir even on PASS
#
# SASSO_FLAKE only redirects the OVERLAY half (`pkgs.sasso` in the guest). The
# `nix run` / `nix profile add` steps fetch `flakeRef` from flake.nix by design:
# they are there to prove the URL a user copies out of the README works.
set -euo pipefail

# Must match `tap`/`hostIp` in flake.nix.
TAP=sasso-vm0
HOST_IP=10.0.0.1
GUEST_NET=10.0.0.0/24
TIMEOUT=${TIMEOUT:-900}

# Every external command this script runs, named in one place and checked before
# it does anything at all. Otherwise a host missing one says "iptables: command
# not found" from the middle of the run, with a tap already up — and a host that
# routes with nftables alone is a realistic way to get exactly that.
missing=()
for cmd in dirname id cat mktemp nix ip iptables timeout sleep grep sed rm; do
  command -v "$cmd" >/dev/null || missing+=("$cmd")
done
[[ ${#missing[@]} == 0 ]] || {
  echo "not on PATH: ${missing[*]}" >&2
  echo "see the Needs: line at the top of this script." >&2
  exit 1
}

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

[[ $(id -u) == 0 ]] || {
  echo "run me as root: I create a tap device and a MASQUERADE rule" >&2
  exit 1
}
[[ -e /dev/kvm ]] || {
  echo "no /dev/kvm here — firecracker needs hardware virtualisation" >&2
  exit 1
}

# A stale tap from an earlier run — or anything else holding this /24 — takes
# the route for it, and then the guest boots, configures its address and gets no
# ARP reply from a host that thinks it answers on the other device. That failure
# reads exactly like a broken guest network, so refuse to start instead.
# Asking iproute2 to filter, rather than piping through awk: a check that
# silently no-ops on a host missing a tool is worse than no check.
squatters=$(ip -brief addr show to "$HOST_IP/24")
[[ -z $squatters ]] || {
  echo "$HOST_IP/24 is already on:" >&2
  echo "$squatters" >&2
  echo "remove it (ip link del <dev>) — this /24 has to be ours alone." >&2
  echo "If that is our own tap, a run may still be live: firecracker will fail" >&2
  echo "with ioctl(TUNSETIFF): Device or resource busy rather than share it." >&2
  exit 1
}

args=()
[[ -n ${SASSO_FLAKE:-} ]] && args+=(--override-input sasso "$SASSO_FLAKE")

rundir=$(mktemp -d /tmp/sasso-vm.XXXXXX)
echo "==> building the guest (rundir $rundir)"
# --no-write-lock-file: this flake is deliberately unlocked (it wants today's
# nixpkgs), and a run should not leave a root-owned flake.lock in the checkout.
nix build "$here#nixosConfigurations.sasso-vm.config.microvm.declaredRunner" \
  "${args[@]}" --no-write-lock-file --out-link "$rundir/runner"

# The runner ships tap-up/tap-down scripts, but they hand the device to a
# `microvm` user that only exists on a host running microvm.nix' own host module
# — on anything else they fail with `invalid user "microvm"`. Firecracker runs as
# root here, so an unowned tap is all this needs.
added_nat=0
made_tap=0
fwd_was=
vm=
# Idempotent: called once the verdict is in, and again by the EXIT trap.
# It tears down only what this run created, and kills only its own guest. An
# earlier version deleted `$TAP` and pkill'd by name unconditionally, so a
# second run that bailed out took the *live* run's tap with it — which shows up
# minutes later as `Failed to write to tap` on the host and
# `Could not resolve host: github.com` in the guest.
cleanup() {
  if [[ -n $vm ]]; then
    kill "$vm" 2>/dev/null || true
    vm=
  fi
  if [[ $added_nat == 1 ]]; then
    iptables -t nat -D POSTROUTING -s "$GUEST_NET" -j MASQUERADE 2>/dev/null || true
    added_nat=0
  fi
  if [[ -n $fwd_was ]]; then
    echo "$fwd_was" >/proc/sys/net/ipv4/ip_forward 2>/dev/null || true
    fwd_was=
  fi
  if [[ $made_tap == 1 ]]; then
    ip link del "$TAP" 2>/dev/null || true
    made_tap=0
  fi
  return 0
}
trap cleanup EXIT
ip tuntap add dev "$TAP" mode tap
made_tap=1
ip addr add "$HOST_IP/24" dev "$TAP"
ip link set "$TAP" up

# The guest's only way out. Both halves are undone on the way out, so a run
# leaves the host's networking exactly as it found it — a smoke test has no
# business turning a machine into a router permanently. (`sysctl` is not always
# on PATH; /proc always is.)
fwd_now=$(cat /proc/sys/net/ipv4/ip_forward)
if [[ $fwd_now != 1 ]]; then
  fwd_was=$fwd_now
  echo 1 >/proc/sys/net/ipv4/ip_forward
fi
if ! iptables -t nat -C POSTROUTING -s "$GUEST_NET" -j MASQUERADE 2>/dev/null; then
  iptables -t nat -A POSTROUTING -s "$GUEST_NET" -j MASQUERADE
  added_nat=1
fi

echo "==> booting (console log: $rundir/vm.log)"
cd "$rundir"
timeout "$TIMEOUT" ./runner/bin/microvm-run >vm.log 2>&1 &
vm=$!
# Don't wait for the process: the guest powers itself off when the smoke run
# ends, and firecracker halts rather than exiting on some kernels, which would
# cost the full timeout every single run. Wait for the verdict instead.
while kill -0 "$vm" 2>/dev/null; do
  if grep -aq '@@ RESULT:' vm.log; then
    sleep 2 # let the console drain
    break
  fi
  sleep 2
done
cleanup

echo "==> results"
# The guest's own markers, with the ANSI the systemd console emits stripped.
sed -e 's/\x1b\[[0-9;?]*[a-zA-Z]//g' vm.log |
  grep -aE '^\[.*sasso-smoke|@@|^ok |^FAIL ' || true

if grep -aq '@@ RESULT: PASS' vm.log; then
  echo "==> PASS"
  # The rundir holds more than a log: `runner` is a nix out-link, i.e. a GC root
  # pinning the whole guest closure, and the store overlay image lands here too.
  # Leaving both behind means every run permanently costs a guest. A failing run
  # keeps them — that console log is the only evidence of what went wrong.
  if [[ -n ${KEEP_RUNDIR:-} ]]; then
    echo "    (kept $rundir)"
  else
    cd /
    rm -rf "$rundir"
  fi
else
  echo "==> FAIL (full console log: $rundir/vm.log)"
  exit 1
fi

{ runCommandCC }:
# Resolve-and-copy a path with RESOLVE_IN_ROOT confinement. Used by the
# qemu-vm module to lift a guest's kernel/initrd/cmdline out of its
# (guest-writable) rootfs without a malicious guest being able to redirect the
# read at a host file. See confine-copy.c.
runCommandCC "confine-copy" { } ''
  mkdir -p "$out/bin"
  cc -O2 -Wall -o "$out/bin/confine-copy" ${./confine-copy.c}
''

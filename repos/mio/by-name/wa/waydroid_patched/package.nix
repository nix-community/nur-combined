{
  writeShellScriptBin,
}:

writeShellScriptBin "waydroid" ''
  echo "ERROR: Waydroid execution blocked."
  echo ""
  echo "GrapheneOS developers and security experts strongly advise against using Waydroid"
  echo "for any security-sensitive tasks. Waydroid bypasses core Android security features"
  echo "(app sandbox, SELinux) and operates as a root container sharing the host kernel,"
  echo "which poses a significant security risk."
  echo ""
  echo "To address these concerns, this patched version intentionally disables Waydroid."
  echo "Please use a native hardened OS like GrapheneOS, or a fully isolated virtual machine"
  echo "for running Android applications securely."
  exit 1
''

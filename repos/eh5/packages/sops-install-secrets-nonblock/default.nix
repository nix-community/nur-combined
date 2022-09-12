{ runCommandCC, writeShellScriptBin, sops-install-secrets }:
let
  ptrace-wrapper = runCommandCC "ptrace-wrapper" { } ''
    $CC ${./ptrace-wrapper.c} -o $out
  '';
in
(writeShellScriptBin "sops-install-secrets" ''
  ${ptrace-wrapper} ${sops-install-secrets}/bin/sops-install-secrets "$@"
'') // {
  passthru.original = sops-install-secrets;
}

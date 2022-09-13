{ lib, runCommandCC, writeShellScriptBin, sops-install-secrets, debug ? false }:
let
  pname = lib.getName sops-install-secrets;
  ptrace-wrapper = runCommandCC "ptrace-wrapper" { } ''
    $CC ${./ptrace-wrapper.c} -O2 -o $out ${lib.optionalString (!debug) "-DNDEBUG"}
  '';
in
(writeShellScriptBin pname ''
  ${ptrace-wrapper} ${sops-install-secrets}/bin/${pname} "$@"
'').overrideAttrs (_: {
  inherit pname;
  name = "${pname}-nonblock";
  passthru.original = sops-install-secrets;
})

{
  mkShell,
  lib,
  writeShellScriptBin,
  ...
}:
apps:
mkShell {
  buildInputs = lib.mapAttrsToList (
    n: v:
    writeShellScriptBin n ''
      exec nix run .#${n} -- "$@"
    ''
  ) apps;
}

{ lib
, resholve

  # Dependencies
, bash
, findutils
, gnugrep
, nix # TODO: config.nix.package?
, uutils-coreutils
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };
in
resholve.writeScriptBin "audit-nix-roots"
{
  interpreter = getExe bash;
  inputs = [ findutils gnugrep nix uutils-coreutils' ];
  execer = [
    "cannot:${getExe' nix "nix-store"}"
    "cannot:${getExe' uutils-coreutils' "date"}"
    "cannot:${getExe' uutils-coreutils' "realpath"}"
    "cannot:${getExe' uutils-coreutils' "rm"}"
    "cannot:${getExe' uutils-coreutils' "stat"}"
  ];
}
  (readFile ./assets/audit-nix-roots.sh)

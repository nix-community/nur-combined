{ lib
, resholve

  # Dependencies
, bash
, findutils
, gnugrep
, gnused
, nix # TODO: config.nix.package?
, uutils-coreutils-noprefix
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe getExe';
in
resholve.writeScriptBin "audit-nix-roots"
{
  interpreter = getExe bash;
  inputs = [ findutils gnugrep gnused nix uutils-coreutils-noprefix ];
  execer = [
    "cannot:${getExe' nix "nix-store"}"
    "cannot:${getExe' uutils-coreutils-noprefix "date"}"
    "cannot:${getExe' uutils-coreutils-noprefix "realpath"}"
    "cannot:${getExe' uutils-coreutils-noprefix "rm"}"
    "cannot:${getExe' uutils-coreutils-noprefix "stat"}"
  ];
}
  (readFile ./assets/audit-nix-roots.sh)

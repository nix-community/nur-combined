{ lib
, resholve

  # Dependencies
, bash
, git
, gnugrep
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "git-remote" {
  interpreter = getExe bash;
  inputs = [ git gnugrep ];
  execer = [ "cannot:${getExe git}" ];
} (readFile ./resources/git-remote)

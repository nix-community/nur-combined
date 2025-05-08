{ lib
, resholve

  # Dependencies
, bash
, coreutils
, git
, moreutils
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "add-words" {
  interpreter = getExe bash;
  inputs = [ coreutils git moreutils ];
  execer = [ "cannot:${getExe git}" ];
} (readFile ./resources/add-words)

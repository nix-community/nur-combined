{ lib
, resholve

  # Dependencies
, bash
, git
, jujutsu
, moreutils
, uutils-coreutils
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };
in
resholve.writeScriptBin "add-words" {
  interpreter = getExe bash;
  inputs = [ git jujutsu moreutils uutils-coreutils' ];
  execer = [
    "cannot:${getExe git}"
    "cannot:${getExe jujutsu}"
  ];
} (readFile ./assets/add-words.sh)

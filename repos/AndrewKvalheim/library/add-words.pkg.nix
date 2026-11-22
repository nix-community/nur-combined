{ lib
, resholve

  # Dependencies
, bash
, git
, jujutsu
, moreutils
, uutils-coreutils-noprefix
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "add-words" {
  interpreter = getExe bash;
  inputs = [ git jujutsu moreutils uutils-coreutils-noprefix ];
  execer = [
    "cannot:${getExe git}"
    "cannot:${getExe jujutsu}"
  ];
} (readFile ./assets/add-words.sh)

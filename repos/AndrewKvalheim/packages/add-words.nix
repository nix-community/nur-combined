{ resholve

  # Dependencies
, bash
, coreutils
, git
, moreutils
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "add-words" {
  interpreter = "${bash}/bin/bash";
  inputs = [ coreutils git moreutils ];
  execer = [ "cannot:${git}/bin/git" ];
} (readFile ./resources/add-words)

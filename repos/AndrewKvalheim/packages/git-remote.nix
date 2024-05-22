{ resholve

  # Dependencies
, bash
, git
, gnugrep
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "git-remote" {
  interpreter = "${bash}/bin/bash";
  inputs = [ git gnugrep ];
  execer = [ "cannot:${git}/bin/git" ];
} (readFile ./resources/git-remote)

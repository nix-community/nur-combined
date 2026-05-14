{ lib
, resholve

  # Dependencies
, bash
, fastnbt-tools
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "git-diff-anvil" {
  interpreter = getExe bash;
  inputs = [ fastnbt-tools ];
} (readFile ./assets/git-diff-anvil.sh)

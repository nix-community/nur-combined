{ resholve

  # Dependencies
, bash
, fastnbt-tools
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "git-diff-anvil" {
  interpreter = "${bash}/bin/bash";
  inputs = [ fastnbt-tools ];
} (readFile ./resources/git-diff-anvil)

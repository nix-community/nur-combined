{ lib
, resholve

  # Dependencies
, bash
, gawk
, uutils-coreutils-noprefix
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "jj-dynamic-default-description" {
  interpreter = getExe bash;
  inputs = [ gawk uutils-coreutils-noprefix ];
} (readFile ./assets/jj-dynamic-default-description.sh)

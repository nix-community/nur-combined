{ lib
, resholve

  # Dependencies
, bash
, gawk
, uutils-coreutils
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;

  uutils-coreutils' = uutils-coreutils.override { prefix = null; };
in
resholve.writeScriptBin "jj-dynamic-default-description" {
  interpreter = getExe bash;
  inputs = [ gawk uutils-coreutils' ];
} (readFile ./assets/jj-dynamic-default-description.sh)

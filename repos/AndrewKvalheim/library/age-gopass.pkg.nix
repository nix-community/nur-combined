{ lib
, resholve

  # Dependencies
, age
, bash
, gopass
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "age-gopass" {
  interpreter = getExe bash;
  inputs = [ age gopass ];
  execer = [
    "cannot:${getExe age}"
    "cannot:${getExe gopass}"
  ];
} (readFile ./assets/age-gopass.sh)

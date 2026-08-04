{ lib
, resholve

  # Dependencies
, bash
, netcat
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "may-upgrade" {
  interpreter = getExe bash;
  inputs = [ netcat ];
} (readFile ./assets/may-upgrade.sh)

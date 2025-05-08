{ lib
, resholve

  # Dependencies
, bash
, gopass-await
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "gopass-env" {
  interpreter = getExe bash;
  inputs = [ gopass-await ];
  execer = [ "cannot:${getExe gopass-await}" ];
} (readFile ./resources/gopass-env)

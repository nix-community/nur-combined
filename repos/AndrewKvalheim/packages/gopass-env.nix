{ resholve

  # Dependencies
, bash
, gopass-await
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "gopass-env" {
  interpreter = "${bash}/bin/bash";
  inputs = [ gopass-await ];
  execer = [ "cannot:${gopass-await}/bin/gopass-await" ];
} (readFile ./resources/gopass-env)

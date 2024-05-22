{ resholve

  # Dependencies
, bash
, gopass
, ydotool
}:

let
  inherit (builtins) readFile;
in
resholve.writeScriptBin "gopass-ydotool" {
  interpreter = "${bash}/bin/bash";
  inputs = [ gopass ydotool ];
  execer = [ "cannot:${gopass}/bin/gopass" ];
} (readFile ./resources/gopass-ydotool)

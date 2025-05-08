{ lib
, resholve

  # Dependencies
, bash
, gopass
, ydotool
}:

let
  inherit (builtins) readFile;
  inherit (lib) getExe;
in
resholve.writeScriptBin "gopass-ydotool" {
  interpreter = getExe bash;
  inputs = [ gopass ydotool ];
  execer = [ "cannot:${getExe gopass}" ];
} (readFile ./resources/gopass-ydotool)

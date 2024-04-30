{ pkgs, packages, overlays, ... }:
let
  # text generated with https://patorjk.com/software/taag/
  # kitty from https://user.xmission.com/~emailbox/ascii_cats.htm by hjw
  packagesList = pkgs.lib.attrValues packages;
in
with builtins; pkgs.writeScriptBin "mur" ''
  #!${pkgs.bash}/bin/bash
  ${pkgs.lolcat}/bin/lolcat --animate --duration=1 --speed=60 ${./ascii.art}

  echo "or mur～
  Packages (${toString (length packagesList)}):
  ${concatStringsSep "\n" (map (p: "· ${p.pname} (${p.version}):\n\t${if p.meta ? longDescription then p.meta.longDescription else p.meta.description}") packagesList)}
  "''

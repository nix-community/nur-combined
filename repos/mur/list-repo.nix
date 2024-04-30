{ pkgs, packages, overlays, ... }:
let
  # text generated with https://patorjk.com/software/taag/
  # kitty from https://user.xmission.com/~emailbox/ascii_cats.htm by hjw
  art = builtins.readFile ./ascii.art;
  packagesList = pkgs.lib.attrValues packages;
in
with builtins; pkgs.writeScriptBin "mur" ''
  #!/usr/bin/env bash
  cat << "EOF"
  ${art}EOF
  echo "or mur～

  Packages (${toString (length packagesList)}):
  ${concatStringsSep "\n" (map (p: "· ${p.pname} (${p.version}):\n    ${if p.meta ? longDescription then p.meta.longDescription else p.meta.description}") packagesList)}
  "''

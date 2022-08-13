{ lib
, writeShellScriptBin
, flake
}:
let
  inherit (flake.outputs.colors) colors;
  inherit (lib) attrNames concatStringsSep;
  sedstep = key: "sed 's;%${key}%;${colors.${key}};g'";
in writeShellScriptBin "colorpipe" ''
  ${concatStringsSep " | " (map sedstep (attrNames colors))}
''

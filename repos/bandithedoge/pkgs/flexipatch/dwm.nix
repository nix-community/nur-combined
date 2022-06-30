{
  pkgs,
  sources,
  conf ? null,
  patches ? null,
}:
pkgs.stdenv.mkDerivation rec {
  inherit (sources.dwm-flexipatch) src pname version;

  buildInputs = with pkgs; [xorg.libX11 xorg.libXinerama xorg.libXft];

  prePatch =
    ''
      sed -i "s@/usr/local@$out@" config.mk

    ''
    + (
      let
        patchesFile =
          if pkgs.lib.isDerivation conf || builtins.isPath patches
          then patches
          else pkgs.writeText "patches.def.h" patches;
      in
        pkgs.lib.optionalString (conf != null) "cp ${patchesFile} patches.def.h"
    );

  postPatch = let
    configFile =
      if pkgs.lib.isDerivation conf || builtins.isPath conf
      then conf
      else pkgs.writeText "config.def.h" conf;
  in
    pkgs.lib.optionalString (conf != null) "cp ${configFile} config.def.h";

  inherit (pkgs.dwm) meta;
}

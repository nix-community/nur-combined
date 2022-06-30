{
  pkgs,
  sources,
  conf ? null,
  patches ? null,
  extraLibs ? [],
  mkConfig ? null,
}: let
  source = sources.dmenu-flexipatch;
in
  pkgs.stdenv.mkDerivation rec {
    inherit (source) pname version src;

    buildInputs = with pkgs; [
      xorg.libX11
      xorg.libXinerama
      xorg.libXft
      zlib
    ];

    configFile =
      pkgs.lib.optionalString (conf != null)
      (pkgs.writeText "config.def.h" conf);

    preConfigure = let
      patchesFile =
        if pkgs.lib.isDerivation conf || builtins.isPath patches
        then patches
        else pkgs.writeText "patches.def.h" patches;
      mkConfigFile =
        if pkgs.lib.isDerivation mkConfig || builtins.isPath mkConfig
        then mkConfig
        else pkgs.writeText "config.mk" mkConfig;
    in
      ''
        sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
        ${pkgs.lib.optionalString (patches != null) "cp ${patchesFile} patches.def.h"}
        ${pkgs.lib.optionalString (mkConfig != null) "cp ${mkConfigFile} config.mk"}
      ''
      + pkgs.lib.optionalString (conf != null) "cp ${configFile} config.def.h";

    makeFlags = ["CC:=$(CC)"];

    postPatch = ''
      sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
      sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
    '';

    inherit (pkgs.dmenu) meta;
  }

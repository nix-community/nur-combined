{ stdenv, lib, fetchurl, buildFHSUserEnv, mono, sqlite }:
let
  pkg = stdenv.mkDerivation rec {
    pname = "mfbot-binary";
    version = "5.6.0.0";

    src = fetchurl {
      url = "https://download.mfbot.de/v${version}/MFBot_Konsole_x86_64";
      hash = "sha256-qeMzic45+nyZwyiRM8GoAR0x3oRv5kSxaFgrhaPc7NA=";
      executable = true;
    };

    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    doCheck = false;
    installPhase = ''
      mkdir -p $out/bin/
      cp $src $out/bin/MFBot_Konsole
    '';
    dontFixup = true;
    doInstallCheck = false;

    meta = {
      description = "The new generation of shakes and fidget bot!";
      homepage = "https://mfbot.de";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
in buildFHSUserEnv {
  name = "mfbot";
  targetPkgs = pkgs: (with pkgs; [ mono sqlite ]);
  runScript = "${pkg.outPath}/bin/MFBot_Konsole";
}

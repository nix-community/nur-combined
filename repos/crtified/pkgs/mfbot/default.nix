{ stdenv, lib, fetchurl, buildFHSUserEnv, mono, sqlite }:
let
  pkg = stdenv.mkDerivation rec {
    pname = "mfbot-binary";
    version = "5.5.0.1";

    src = fetchurl {
      url = "https://download.mfbot.de/v${version}/MFBot_Konsole_x86_64";
      hash = "sha256-5EP96W61z6Yhzm0ghkJocj5lochr21m6roCGu59932s=";
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

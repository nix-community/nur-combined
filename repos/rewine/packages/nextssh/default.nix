{ lib
, stdenv
, fetchurl
, runtimeShell
, writeText
, appimage-run
, writeShellScriptBin
}:
let
  pname = "nxshell-app";
  version = "1.3.0";
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  app = stdenv.mkDerivation
    rec {
      inherit pname version dontUnpack dontConfigure dontBuild;

      src = fetchurl {
        url = "https://download.xzhshch.com/NextSSH-1.3.0.AppImage";
        sha256 = "sha256-rQ/lxHcZuuhAZUBNdyTdUmQ8nyr+T8pmJg2xMxJrw1Y=";
      };

      buildInputs = [ appimage-run ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp $src $out/${pname}.AppImage
        runHook postInstall
      '';

      meta = with lib; {
        homepage = "https://xzhshch.com";
        description = "An easy to use new terminal";
        license = "unknown";
        platforms = platforms.linux;
      };
    };
in
writeShellScriptBin "nextssh" ''
  ${appimage-run}/bin/appimage-run  ${app}/${app.pname}.AppImage "$@"
''

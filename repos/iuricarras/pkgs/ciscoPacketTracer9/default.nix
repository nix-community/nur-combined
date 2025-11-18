{
  lib,
  pkgs,
  stdenvNoCC,
  requireFile,
  dpkg,
  version ? "9.0.0",
  packetTracerSource ? null,
  appimageTools,
  libpng,
  libxkbfile,
  brotli,
}: let
  hashes = {
    "9.0.0" = "sha256-3ZrA1Mf8N9y2j2J/18fm+m1CAMFEklJuVhi5vRcu2SA=";
  };
  names = {
    "9.0.0" = "CiscoPacketTracer_900_Ubuntu_64bit.deb";
  };

  pname = "CiscoPacketTracer";

  unwrapped = stdenvNoCC.mkDerivation {
    pname = "CiscoPacketTracer-9.0.0-unwrapped";
    inherit version;

    src =
      if (packetTracerSource != null)
      then packetTracerSource
      else
        requireFile {
          name = names.${version};
          hash = hashes.${version};
          url = "https://www.netacad.com";
        };

    nativeBuildInputs = [
      dpkg
    ];

    unpackPhase = ''
      runHook preUnpack

      dpkg-deb -x $src $out
      chmod 755 "$out"

      runHook postUnpack
    '';
  };

  src = "${unwrapped}/opt/pt/packettracer.AppImage";

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;

    postExtract = ''
      substituteInPlace $out/CiscoPacketTracer-9.0.0.desktop --replace-fail 'Exec=@EXEC_PATH@ %f' 'Exec=${pname}'
      substituteInPlace $out/CiscoPacketTracer-9.0.0.desktop --replace-fail 'Icon=app' 'Icon=cisco-packet-tracer-9'
    '';
  };
in
  appimageTools.wrapType2 rec {
    inherit pname version src;
    extraPkgs = ps:
      with ps; [
        libpng
        libxkbfile
        brotli
      ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${appimageContents}/CiscoPacketTracer-9.0.0.desktop $out/share/applications/

      mkdir -p $out/share/icons/hicolor/48x48/apps
      cp -r ${appimageContents}/app.png $out/share/icons/hicolor/48x48/apps/cisco-packet-tracer-9.png
      cp -r ${appimageContents}/usr/share/icons/gnome/48x48/mimetypes $out/share/icons/hicolor/48x48/mimetypes
      cp -r ${appimageContents}/usr/share/mime $out/share/mime

    '';
    meta = {
      description = "Network simulation tool from Cisco";
      homepage = "https://www.netacad.com/courses/packet-tracer";
      license = lib.licenses.unfree;
      mainProgram = "CiscoPacketTracer-9.0.0";
      platforms = ["x86_64-linux"];
    };
  }

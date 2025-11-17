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
in
  appimageTools.wrapType2 rec {
    inherit pname version;
    src = "${unwrapped}/opt/pt/packettracer.AppImage";
    extraPkgs = ps:
      with ps; [
        libpng
        libxkbfile
        brotli
      ];
    meta = {
      description = "Network simulation tool from Cisco";
      homepage = "https://www.netacad.com/courses/packet-tracer";
      license = lib.licenses.unfree;
      mainProgram = "CiscoPacketTracer-9.0.0";
      platforms = ["x86_64-linux"];
    };
  }

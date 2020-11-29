# This is currently quite weird to use,
# because you have to manually install the `v4l2loopback`
# kernel module using:
# 
# config.boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
# 
# in you configuration.

{ fetchFromGitHub
, pkgs
, stdenv
, deno
, xrandr
, ffmpeg
}:

let
  pname = "mon2cam";
  version = "ecf8948";
in
stdenv.mkDerivation rec {
  inherit pname version;

  dontPatchShebangs = true;
  dontBuild = true;

  src = fetchFromGitHub {
    owner = "ShayBox";
    repo = "Mon2Cam";
    rev = "ecf8948884e59939944d59651b4d02f53519b781";
    sha256 = "sha256-l4kLC64OOcPBRn2VSxqG/FIxLxxPozDk78fG50gI3YI=";
  };

  buildInputs = [
    ffmpeg
    xrandr
    deno
  ];

  installPhase = ''
    # Create folders and move files
    mkdir -p $out/{share/,bin}
    mv src $out/share/Mon2Cam

    # Create shell script
    echo "#/bin/sh" > $out/bin/mon2cam
    echo "${deno}/bin/deno run --unstable -A $out/share/Mon2Cam/mod.ts -- $@" >> $out/bin/mon2cam
    chmod +x $out/bin/mon2cam
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/ShayBox/Mon2Cam";
    description = "Workaround for multi-monitor Discord screensharing.";
    platforms = platforms.linux;
  };
}

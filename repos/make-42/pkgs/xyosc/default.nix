{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "xyosc";
  version = "0.0.1";

  buildInputs = with pkgs; [
    gcc
    go
    glfw
    pkg-config
    xorg.libX11.dev
    xorg.libXrandr.dev
    xorg.libXcursor.dev
    xorg.libXinerama.dev
    xorg.libXi.dev
    xorg.libXxf86vm.dev
    libglvnd
    libxkbcommon
    libpulseaudio
    alsa-lib
    libjack2
  ];

  nativeBuildInputs = with pkgs; [pkg-config makeWrapper];

  subPackages = ["."];

  src = fetchFromGitHub {
    owner = "make-42";
    repo = "xyosc";
    rev = "b623e69976258a7433b220ff98e4c7fd6cb7e907";
    hash = "sha256-ktDlJuPALkxr5F2+SiuVyiwnxJF89FBrimnygjRSIcM=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "A simple XY-oscilloscope written in Go.";
    homepage = "https://github.com/make-42/xyosc";
    license = licenses.gpl3;
    maintainers = [];
    platforms = platforms.linux;
  };

  postInstall = ''
    wrapProgram "$out/bin/xyosc" \
    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      pkgs.glfw
      pkgs.pkg-config
      pkgs.xorg.libX11.dev
      pkgs.xorg.libXrandr.dev
      pkgs.xorg.libXcursor.dev
      pkgs.xorg.libXinerama.dev
      pkgs.xorg.libXi.dev
      pkgs.xorg.libXxf86vm.dev
      pkgs.libxkbcommon
      pkgs.libglvnd
      pkgs.libpulseaudio
      pkgs.alsa-lib
      pkgs.libjack2
    ]}
  '';
}

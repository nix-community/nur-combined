{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  meson,
  ninja,
  pkg-config,
  rustc,
  libbsd,
  libcamera,
  gtk3,
  libtiff,
  zbar,
  libjpeg,
  libexif,
  libraw,
  libpulseaudio,
  ffmpeg-headless,
  v4l-utils,
  makeWrapper,
  python3,
}: let
  runtimePath = lib.makeBinPath [v4l-utils ffmpeg-headless];
in
  stdenv.mkDerivation rec {
    pname = "millipixels";
    version = "0.22.0";

    src = fetchFromGitLab {
      owner = "Librem5";
      repo = pname;
      rev = "v${version}";
      domain = "source.puri.sm";
      hash = "sha256-pRREQRYyD9+dpRvcfsNiNthFy08Yeup9xDn+x+RWDrE=";
    };

    nativeBuildInputs = [
      glib
      meson
      ninja
      pkg-config
      rustc
      makeWrapper
    ];

    buildInputs = [
      libbsd
      libcamera
      gtk3
      libtiff
      zbar
      libpulseaudio
      libraw
      libexif
      libjpeg
      python3
    ];

    preFixup = ''
      wrapProgram $out/bin/millipixels \
        --prefix PATH : ${lib.escapeShellArg runtimePath}
    '';
  }

{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  git,
  qmake,
  wrapQtAppsHook,
  pkg-config,
  libnotify,
  qtbase,
  qttools,

  withFFmpeg ? true,
  ffmpeg_4,
}:

let
  vitamtp = pkgs.callPackage ./vitamtp.nix { };
in
stdenv.mkDerivation rec {
  pname = "qcma";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "codestation";
    repo = pname;
    rev = "65f0eab8ca0640447d2e84cdc5fadc66d2c07efb";
    hash = "sha256-AxbWZlziQdL3HnCf9kqylqBnWXVmC0I9pqoFXQAnD8U=";
  };

  buildInputs = [
    vitamtp
    libnotify
    qtbase
  ]
  ++ (lib.optional withFFmpeg ffmpeg_4);

  nativeBuildInputs = [
    git
    qmake
    wrapQtAppsHook
    pkg-config
    qttools
  ];

  qmakeFlags = lib.optional (!withFFmpeg) "CONFIG+=DISABLE_FFMPEG";

  # https://discourse.nixos.org/t/building-derivation-fails-with-generic-makefile-error-manually-building-in-arch-seems-to-work-fine/55168/6
  preBuild = ''
    lrelease-pro qcma.pro
  '';

  meta = with lib; {
    description = "Cross-platform content manager assistant for the PS Vita";
    homepage = "https://codestation.github.io/qcma/";
    license = licenses.gpl3;
    platforms = platforms.unix;
    # currently results in empty derivation
    broken = stdenv.isDarwin;
    mainProgram = "qcma";
  };
}

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
  qt6,

  withFFmpeg ? true,
  ffmpeg,
}:

let
  vitamtp = pkgs.callPackage ./vitamtp.nix { };
in
stdenv.mkDerivation rec {
  pname = "qcma";
  version = "0.4.1-unstable-2025-07-14";

  src = fetchFromGitHub {
    owner = "codestation";
    repo = pname;
    rev = "26ad896537288712fe1cdda23e310d461a0d95af";
    hash = "sha256-OFP7ZpTjiJYzz7uVyscemNsBHYnQOu5hGdi7xfLPYnM=";
  };

  passthru = { inherit vitamtp; };

  buildInputs = [
    vitamtp
    libnotify
    qt6.qtbase
  ]
  ++ (lib.optional withFFmpeg ffmpeg);

  nativeBuildInputs = [
    git
    qmake
    wrapQtAppsHook
    pkg-config
    qt6.qttools
  ];

  qmakeFlags = lib.optional (!withFFmpeg) "CONFIG+=DISABLE_FFMPEG";

  # postInstall is used to avoid conflicting with the non-macOS phase
  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -prv gui/qcma.app $out/Applications/qcma.app
  '';

  # https://discourse.nixos.org/t/building-derivation-fails-with-generic-makefile-error-manually-building-in-arch-seems-to-work-fine/55168/6
  preBuild = ''
    lrelease-pro qcma.pro
  '';

  meta = with lib; {
    description = "Cross-platform content manager assistant for the PS Vita";
    homepage = "https://codestation.github.io/qcma/";
    license = licenses.gpl3;
    platforms = platforms.unix;
    mainProgram = "qcma";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6Packages,
}:

stdenv.mkDerivation {
  pname = "aether";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "aether";
    rev = "46ae72a8d1c57eac3eb907504b8d2e14f6fa7c9a";
    hash = "sha256-vCole8LVbK4CmTxsH2j5y8jvFDl8IjSxCIAv42gwDJo=";
  };

  nativeBuildInputs = [
    cmake
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
     qt6Packages.qtwayland
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp aether "$out/bin/aether"
  '';

  meta = {
    description = "A minimal image viewer";
    homepage = "https://github.com/yashsio/aether";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "aether";
  };
}

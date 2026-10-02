{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6Packages,
}:

stdenv.mkDerivation {
  pname = "aether";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "yashsio";
    repo = "aether";
    rev = "2d13a4d84c294c2012b13fa4ceaf004037c9fa3e";
    hash = "sha256-V1QSA7/84+s3azo8KhbJIjc2jjfqiTOXMuN9tz+lgPo=";
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

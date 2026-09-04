{
  lib,
  stdenv,
  fetchFromGitHub,
  kpackage,
  kwin,
  coreutils,
  zip,
  gnumake,
}:

stdenv.mkDerivation rec {
  pname = "mouse-tiler";
  version = "6.5.0";

  src = fetchFromGitHub {
    owner = "rxappdev";
    repo = "MouseTiler";
    # 3.2 was released on KDE Store but not tagged.
    rev = "v${version}";
    hash = "sha256-jgtNOu98Z8iDTo5zNvPmGkgP1eGLkKL510DpZZ9xyvA=";
  };

  nativeBuildInputs = [
    kpackage
    coreutils
    zip
    gnumake
  ];

  buildInputs = [
    kwin
  ];

  dontWrapQtApps = true;

  buildPhase = ''
    make build
  '';

  installPhase = ''
    runHook preInstall

    kpackagetool6 --type KWin/Script --install mousetiler.kwinscript --packageroot $out/share/kwin/scripts

    runHook postInstall
  '';

  meta = {
    description = "The fastest, simplest tiler for KDE Plasma 6+ that gives you full freedom at your fingertip. No need to remember dozens of keyboard shortcuts or be limited by a fixed tile layout.";
    homepage = "https://github.com/rxappdev/MouseTiler";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}

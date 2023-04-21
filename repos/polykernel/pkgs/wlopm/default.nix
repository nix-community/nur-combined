{
  stdenv,
  lib,
  fetchFromSourcehut,
  pkg-config,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation rec {
  pname = "wlopm";
  version = "master";

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = pname;
    rev = "38af45c79771da1ef52309d101e881aaef94a823";
    sha256 = "sha256-BVgq0Ht4Otid+McnwwmzdY7flqcBPe5br5879nyPgAE=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland.dev
  ];

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple client implementing zwlr-output-power-management-v1.";
    homepage = "https://git.sr.ht/~leon_plickat/wlopm";
    license = licenses.gpl3;
    maintainers = with maintainers; [ polykernel ];
    platforms = platforms.linux;
  };
}

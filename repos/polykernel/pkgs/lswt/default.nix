{
  stdenv,
  lib,
  fetchFromSourcehut,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation rec {
  pname = "lswt";
  version = "master";

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = pname;
    rev = "ed1ae054d9af3c345f9f2c2003d179932c0c6b60";
    sha256 = "sha256-Tiua9M2CJsYfmtmRXgR9ofmhwP8pRiYGbJdlBThWKMM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
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
    description = "Simple utility to list Wayland toplevels.";
    homepage = "https://git.sr.ht/~leon_plickat/lswt";
    license = licenses.gpl3;
    maintainers = with maintainers; [ polykernel ];
    platforms = platforms.linux;
  };
}

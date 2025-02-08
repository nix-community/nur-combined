{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  wxGTK32,
  portaudio,
  libGL,
}:

stdenv.mkDerivation rec {
  pname = "3beans";
  version = "0-unstable-2025-02-06";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = "3Beans";
    rev = "0f01c3ac4d0c4a1ba1d029c043d28d9280db46b2";
    hash = "sha256-xK2KUz6r1effwnjWFphkxh8A/jULTkpLD4rSS41X0Eo=";
  };

  buildInputs = [
    wxGTK32
    portaudio
    libGL
  ];
  nativeBuildInputs = [ pkg-config ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail g++ "\$(CXX)"
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications
    cp 3beans $out/bin
  '' + (lib.optionalString (!stdenv.isDarwin) ''
    cp com.hydra.threebeans.desktop $out/share/applications
  '');

  meta = with lib; {
    license = licenses.gpl3;
    description = "A low-level 3DS emulator (maybe)";
    homepage = "https://github.com/Hydr8gon/3Beans";
    platforms = platforms.all;
    mainProgram = "3beans";
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  wxwidgets_3_3,
  portaudio,
  libGL,
}:

stdenv.mkDerivation rec {
  pname = "rokuyon";
  version = "release-unstable-2026-06-14";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = pname;
    rev = "db9c7de8c7a56e1b25cf32136deb09135f23ce2c";
    hash = "sha256-JzHoLpMhxKn68L0YQz995gzu6k5d9Ja/M6gbhSywujM=";
  };

  buildInputs = [
    wxwidgets_3_3
    portaudio
    libGL
  ];
  nativeBuildInputs = [ pkg-config ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail g++ "\$(CXX)"
  '';

  installPhase = ''
    mkdir -p $out/bin
  ''
  + (
    if stdenv.isDarwin then
      # TODO: check if this works
      ''
        contents=$out/Applications/rokuyon.app/Contents
        mkdir -p $contents/{MacOS,Resources}
        cp Info.plist $contents
        cp rokuyon $contents/MacOS/rokuyon
        ln -s $contents/MacOS/rokuyon $out/bin/rokuyon
      ''
    else
      ''
        mkdir -p $out/share/applications
        cp rokuyon $out/bin
        cp com.hydra.rokuyon.desktop $out/share/applications
      ''
  );

  meta = with lib; {
    description = "An experimental N64 emulator";
    homepage = "https://github.com/Hydr8gon/rokuyon";
    license = licenses.gpl3;
    platforms = platforms.all;
    mainProgram = "rokuyon";
    broken = stdenv.isDarwin;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  wxwidgets_3_3,
  portaudio,
  libGL,
  libepoxy,
}:

let
  wxwidgets-newer = wxwidgets_3_3.overrideAttrs (
    final: prev: {
      src = fetchFromGitHub {
        owner = "wxWidgets";
        repo = "wxWidgets";
        rev = "1fd12d7bd6987603b8d63000a593a4286f5cad46";
        fetchSubmodules = true;
        hash = "sha256-DzMW9i6TE+kGb3rXuxhb7lTFlT1A06O+iXzdmFq9Fa4=";
      };
    }
  );
in
stdenv.mkDerivation rec {
  pname = "3beans";
  version = "release-unstable-2026-01-11";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = "3Beans";
    rev = "f95916a9d8ebe275d23c26c24d3ba5ca37725dcf";
    hash = "sha256-+thkkYjJGDOy0KormuNbyE0A+x8mM0yYO/qNZavmF50=";
  };

  buildInputs = [
    wxwidgets-newer
    portaudio
    libGL
    libepoxy
  ];
  nativeBuildInputs = [ pkg-config ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail g++ "\$(CXX)"
  '';

  # The Darwin-specific phase kind works like mac-bundle.sh in the 3Beans repo
  # but is done manually since I don't need to bundle libraries in the app bundle
  installPhase = ''
    mkdir -p $out/bin
  ''
  + (
    if stdenv.isDarwin then
      ''
        contents=$out/Applications/3Beans.app/Contents
        mkdir -p $contents
        cp meta/Info.plist $contents
        mkdir $contents/MacOS
        cp 3beans $contents/MacOS/3beans
        ln -s $contents/MacOS/3beans $out/bin/3beans
      ''
    else
      ''
        mkdir -p $out/share/applications
        cp 3beans $out/bin
        cp meta/com.hydra.threebeans.desktop $out/share/applications
      ''
  );

  meta = with lib; {
    license = licenses.gpl3;
    description = "A low-level 3DS emulator (maybe)";
    homepage = "https://github.com/Hydr8gon/3Beans";
    platforms = platforms.all;
    mainProgram = "3beans";
  };
}

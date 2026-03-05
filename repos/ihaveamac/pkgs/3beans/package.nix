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
        rev = "9720f1fdce0e11313d383a6ceb92275e7910e540";
        fetchSubmodules = true;
        hash = "sha256-vtb716bhRjsoE/rIxlzmwwXCg2Aw4Prqepd3Skbiuh0=";
      };
    }
  );
in
stdenv.mkDerivation rec {
  pname = "3beans";
  version = "release-unstable-2026-02-26";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = "3Beans";
    rev = "3aa773d376cbec3c0ca93d2b557e30a3acae4372";
    hash = "sha256-vGeLeY5nvMbi1gBOXDzngQQ5NMt+iEj1o/1J5x5fZPA=";
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

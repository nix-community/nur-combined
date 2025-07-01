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
  version = "0-unstable-2025-06-28";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = "3Beans";
    rev = "2e7589076c20bb52a20b3d3deeb63df8fc791226";
    hash = "sha256-eM7xN2SYanZ4bGo8NoTY27J3yxdLJfwavUPHdISmqqg=";
  };

  buildInputs = [
    (wxGTK32.override { withWebKit = false; })
    portaudio
    libGL
  ];
  nativeBuildInputs = [ pkg-config ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail g++ "\$(CXX)"
  '';

  # The Darwin-specific phase kind works like mac-bundle.sh in the 3Beans repo
  # but is done manually since I don't need to bundle libraries in the app bundle
  installPhase =
    ''
      mkdir -p $out/bin
    ''
    + (
      if stdenv.isDarwin then
        ''
          contents=$out/Applications/3Beans.app/Contents
          mkdir -p $contents
          cp Info.plist $contents
          mkdir $contents/MacOS
          cp 3beans $contents/MacOS/3beans
          ln -s $contents/MacOS/3beans $out/bin/3beans
        ''
      else
        ''
          mkdir -p $out/share/applications
          cp 3beans $out/bin
          cp com.hydra.threebeans.desktop $out/share/applications
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

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

stdenv.mkDerivation rec {
  pname = "3beans";
  version = "release-unstable-2026-06-12";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = "3Beans";
    rev = "2acde9508348dcf65d383da7f0b56195ea39d125";
    hash = "sha256-ExGy/JB4HeHWzaijQyJiPMLQvWCFE5sNAXKBk7sKNrQ=";
  };

  buildInputs = [
    wxwidgets_3_3
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
        mkdir -p $contents/{MacOS,Resources}
        cp meta/Info.plist $contents
        cp 3beans $contents/MacOS/3beans
        cp icon/mac.icns $contents/Resources/3Beans.icns
        ln -s $contents/MacOS/3beans $out/bin/3beans
      ''
    else
      ''
        mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
        cp 3beans $out/bin
        cp meta/com.hydra.threebeans.desktop $out/share/applications
        cp icon/linux.png $out/share/icons/hicolor/256x256/apps/com.hydra.threebeans.png
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

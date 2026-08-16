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
  pname = "noods";
  version = "release-unstable-2026-08-09";

  src = fetchFromGitHub {
    owner = "Hydr8gon";
    repo = "NooDS";
    rev = "4cb1439c330248b26cdf5f8dbcfa4e5ac53dcda0";
    hash = "sha256-jVibIjDEyyD744gfJ2tm73G8/aHxm5T/i4r85Qk4jqQ=";
  };

  buildInputs = [
    wxwidgets_3_3
    portaudio
    libGL
    #libepoxy
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
    if stdenv.hostPlatform.isDarwin then
      ''
        contents=$out/Applications/NooDS.app/Contents
        mkdir -p $contents/{MacOS,Resources}
        cp meta/Info-macOS.plist $contents/Info.plist
        cp noods $contents/MacOS/NooDS
        cp icon/icon-mac.icns $contents/Resources/NooDS.icns
        ln -s $contents/MacOS/NooDS $out/bin/noods
      ''
    else
      ''
        mkdir -p $out/share/applications $out/share/icons/hicolor/64x64/apps
        cp noods $out/bin
        cp meta/com.hydra.noods.desktop $out/share/applications
        cp icon/icon-linux.png $out/share/icons/hicolor/64x64/apps/com.hydra.threebeans.png
      ''
  );

  meta = with lib; {
    description = "A (hopefully!) speedy DS emulator";
    homepage = "https://github.com/Hydr8gon/NooDS";
    license = licenses.gpl3;
    platforms = platforms.all;
    mainProgram = "noods";
  };
}

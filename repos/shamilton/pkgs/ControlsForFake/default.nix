{ pkgs
, lib
, mkDerivation
, fetchFromGitHub
, meson
, ninja
, pkg-config
, qtbase
, qtdeclarative
, qtgraphicaleffects
, qttranslations
, qtquickcontrols2
, pulseaudio
, libfake
, libvorbis
, libogg
, FakeMicWavPlayer
}:
mkDerivation {

  pname = "ControlsForFake";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "ControlsForFake";
    rev = "master";
    sha256 = "1yv6mv3p77rg7xf4cpz4vxhdhzragg6lfaap2ksi5xp8zdibk8kb";
  };

  nativeBuildInputs = [ qttranslations qtbase pkg-config ninja meson ];

  buildInputs = 
          [ qtquickcontrols2 qtbase ] # Qt Deps
      ++  [ pulseaudio libfake libvorbis libogg FakeMicWavPlayer];

  postPatch = ''
    substituteInPlace controls-for-fake.desktop \
      --replace @Prefix@ "$out"
  '';

  postInstall = ''
    mv $out/bin/ControlsForFake $out/bin/.ControlsForFake-wrapped
    makeWrapper $out/bin/.ControlsForFake-wrapped $out/bin/ControlsForFake \
      --set QML2_IMPORT_PATH "${lib.getBin qtquickcontrols2}/lib/qt-5.12.7/qml:${lib.getBin qtdeclarative}/lib/qt-5.12.7/qml:${qtgraphicaleffects}/lib/qt-5.12.7/qml" \
      --set QT_PLUGIN_PATH "${lib.getBin qtbase}/lib/qt-5.12.7/plugins"
  '';

  meta = with lib; {
    description = "The Qt gui frontend for FakeMicWavPlayer";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/ControlsForFake";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

{
  mkDerivation,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  alsa-lib,
  freetype,
  libjack2,
  lame,
  libogg,
  libpulseaudio,
  libsndfile,
  libvorbis,
  portaudio,
  portmidi,
  qtbase,
  qtdeclarative,
  qtgraphicaleffects,
  qtquickcontrols2,
  qtscript,
  qtsvg,
  qttools,
  qtwebengine,
  qtxmlpatterns,
  nixosTests,
}:

mkDerivation rec {
  pname = "musescore";
  version = "3.6.2-unstable-2025-10-29"; # version = "3.6.2";

  src = fetchFromGitHub {
    owner = "Jojo-Schmitz"; # owner = "musescore";
    repo = "MuseScore";
    rev = "6d355e10220270102f54a328c39fd754f04e51b8"; # rev = "v${version}"; # 3.6.2
    hash = "sha256-AaUT3YaF1iS6Bm/z3gn4ulZU5xHDj24LQ9gqQb2ZkU4="; # sha256 = "sha256-GBGAD/qdOhoNfDzI+O0EiKgeb86GFJxpci35T6tZ+2s=";
  };

  patches = [
    #./remove_qtwebengine_install_hack.patch # for musescore/MuseScore
    #./dtl-gcc14-fix.patch # for musescore/MuseScore
    ./Jojo-Schmitz-remove_qtwebengine_install_hack.patch
  ];

  cmakeFlags = [
    "-DMUSESCORE_BUILD_CONFIG=release"
    "-DUSE_SYSTEM_FREETYPE=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  qtWrapperArgs = [
    # MuseScore JACK backend loads libjack at runtime.
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libjack2 ]}"
    # There are some issues with using the wayland backend, see:
    # https://musescore.org/en/node/321936
    "--set-default QT_QPA_PLATFORM xcb"
  ];

  postInstall = ''
    # Rename binary from mscore to mscore3
    mv $out/bin/mscore $out/bin/mscore3

    ln -s mscore3 $out/bin/musescore3
    rm $out/bin/musescore

    # Update desktop file to use mscore3
    substituteInPlace $out/share/applications/mscore.desktop \
      --replace-fail "Exec=mscore" "Exec=mscore3"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libjack2
    freetype
    lame
    libogg
    libpulseaudio
    libsndfile
    libvorbis
    portaudio
    portmidi # tesseract
    qtbase
    qtdeclarative
    qtgraphicaleffects
    qtquickcontrols2
    qtscript
    qtsvg
    qttools
    qtwebengine
    qtxmlpatterns
  ];

  passthru.tests = nixosTests.musescore;

  meta = with lib; {
    description = "Music notation and composition software";
    homepage = "https://musescore.org/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      vandenoever
      turion
      doronbehar
    ];
    platforms = platforms.linux;
  };
}

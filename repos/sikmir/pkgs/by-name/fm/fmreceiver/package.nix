{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  fftwFloat,
  libsamplerate,
  libsndfile,
  libusb1,
  portaudio,
  rtl-sdr,
  qt5,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fmreceiver";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "JvanKatwijk";
    repo = "sdr-j-fm";
    tag = finalAttrs.version;
    hash = "sha256-U0m9PIB+X+TBoz5FfXMvR/tZjkNIy7B613I7eLT5UIs=";
  };

  patches = [
    # support qwt-6.2.0
    (fetchpatch {
      url = "https://github.com/JvanKatwijk/sdr-j-fm/commit/4ca2f3a28e3e3460dc95be851fcd923e91488573.patch";
      hash = "sha256-tjNsg9Rc8kBn+6UzPsf1WLt+ZRYv8neG/CSyZKjObh0=";
    })
  ];

  postPatch =
    ''
      substituteInPlace fmreceiver.pro \
        --replace-fail "-lqwt-qt5" "-lqwt" \
        --replace-fail "CONFIG" "#CONFIG"
    ''
    + lib.optionalString stdenv.isDarwin ''
      substituteInPlace fmreceiver.pro --replace-fail "-lrt " ""
      substituteInPlace includes/fm-constants.h --replace-fail "<malloc.h>" "<stdlib.h>"
      substituteInPlace devices/rtlsdr-handler/rtlsdr-handler.cpp --replace-fail ".so" ".dylib"
    '';

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    fftwFloat
    libsamplerate
    libsndfile
    libusb1
    portaudio
    libsForQt5.qwt
  ];

  qmakeFlags = [ "CONFIG+=dabstick" ];

  qtWrapperArgs = [
    "--prefix ${lib.optionalString stdenv.isDarwin "DY"}LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [ rtl-sdr ]
    }"
  ];

  installPhase =
    if stdenv.isDarwin then
      ''
        mkdir -p $out/Applications
        mv linux-bin/fmreceiver-2.0.app $out/Applications/fmreceiver.app
        install_name_tool -change {,${libsForQt5.qwt}/lib/}libqwt.6.dylib "$out/Applications/fmreceiver.app/Contents/MacOS/fmreceiver-2.0"
      ''
    else
      ''
        install -Dm755 linux-bin/fmreceiver-2.0 $out/bin/fmreceiver
      '';

  meta = {
    description = "A simple FM receiver";
    homepage = "https://github.com/JvanKatwijk/sdr-j-fm";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

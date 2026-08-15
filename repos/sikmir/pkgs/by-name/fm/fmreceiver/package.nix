{
  lib,
  stdenv,
  fetchFromGitHub,
  fftwFloat,
  libsamplerate,
  libsndfile,
  libusb1,
  portaudio,
  rtl-sdr,
  qt6,
  qt6Packages,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fmreceiver";
  version = "3.20";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "JvanKatwijk";
    repo = "sdr-j-fm";
    tag = finalAttrs.version;
    hash = "sha256-qNSmBVY1n5+DR9k1d+nY11gBrYS7Ah774R2FMgCR4ks=";
  };

  postPatch = ''
    substituteInPlace fmreceiver.pro --replace-fail "CONFIG" "#CONFIG"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace fmreceiver.pro --replace-fail "-lrt " ""
    substituteInPlace includes/fm-constants.h --replace-fail "<malloc.h>" "<stdlib.h>"
    substituteInPlace devices/rtlsdr-handler/rtlsdr-handler.cpp --replace-fail ".so" ".dylib"
  '';

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    wrapGAppsHook3 # required for FileChooser
  ];

  buildInputs = [
    fftwFloat
    libsamplerate
    libsndfile
    libusb1
    portaudio
    qt6Packages.qwt
  ];

  qmakeFlags = [ "CONFIG+=dabstick" ];

  gappsWrapperArgs = [
    "--prefix ${lib.optionalString stdenv.hostPlatform.isDarwin "DY"}LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [ rtl-sdr ]
    }"
  ];

  env.NIX_LDFLAGS = "-lqwt";

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications
        mv linux-bin/fmreceiver-3.20.app $out/Applications/fmreceiver.app
        install_name_tool -change {,${qt6Packages.qwt}/lib/}libqwt.6.dylib "$out/Applications/fmreceiver.app/Contents/MacOS/fmreceiver-3.20"
      ''
    else
      ''
        install -Dm755 linux-bin/fmreceiver-3.20 $out/bin/fmreceiver
      '';

  meta = {
    description = "A simple FM receiver";
    homepage = "https://github.com/JvanKatwijk/sdr-j-fm";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

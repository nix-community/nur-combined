{ lib, stdenv, fetchFromGitHub, fetchpatch, fftwFloat, libsamplerate, libsndfile, libusb1
, portaudio, rtl-sdr, qmake, qwt, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "fmreceiver";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "JvanKatwijk";
    repo = "sdr-j-fm";
    rev = version;
    hash = "sha256-U0m9PIB+X+TBoz5FfXMvR/tZjkNIy7B613I7eLT5UIs=";
  };

  patches = [
    # support qwt-6.2.0
    (fetchpatch {
      url = "https://github.com/JvanKatwijk/sdr-j-fm/commit/4ca2f3a28e3e3460dc95be851fcd923e91488573.patch";
      hash = "sha256-tjNsg9Rc8kBn+6UzPsf1WLt+ZRYv8neG/CSyZKjObh0=";
    })
  ];

  postPatch = ''
    substituteInPlace fmreceiver.pro \
      --replace "-lqwt-qt5" "-lqwt" \
      --replace "CONFIG" "#CONFIG"
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace fmreceiver.pro --replace "-lrt " ""
    substituteInPlace includes/fm-constants.h --replace "<malloc.h>" "<stdlib.h>"
    substituteInPlace devices/rtlsdr-handler/rtlsdr-handler.cpp --replace ".so" ".dylib"
  '';

  nativeBuildInputs = [ qmake wrapQtAppsHook ];

  buildInputs = [ fftwFloat libsamplerate libsndfile libusb1 portaudio qwt ];

  qmakeFlags = [ "CONFIG+=dabstick" ];

  qtWrapperArgs = [
    "--prefix ${lib.optionalString stdenv.isDarwin "DY"}LD_LIBRARY_PATH : ${lib.makeLibraryPath [ rtl-sdr ]}"
  ];

  installPhase = if stdenv.isDarwin then ''
    mkdir -p $out/Applications
    mv linux-bin/fmreceiver-2.0.app $out/Applications/fmreceiver.app
    install_name_tool -change {,${qwt}/lib/}libqwt.6.dylib "$out/Applications/fmreceiver.app/Contents/MacOS/fmreceiver-2.0"
  '' else ''
    install -Dm755 linux-bin/fmreceiver-2.0 $out/bin/fmreceiver
  '';

  meta = with lib; {
    description = "A simple FM receiver";
    inherit (src.meta) homepage;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

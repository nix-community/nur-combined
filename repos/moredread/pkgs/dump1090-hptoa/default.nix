{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, libbladeRF
, libusb
, ncurses
, rtl-sdr
, cmake
, liquid-dsp
}:

stdenv.mkDerivation rec {
  pname = "dump1090";
  version = "git-20200315";

  src = fetchFromGitHub {
    owner = "openskynetwork";
    repo = "dump1090-hptoa";
    rev = "3affd1a7bf03ba2479a15fe944c6ca337c90ed91";
    sha256 = "08zsn33lhk56awzrrgri857b5d5l78hl7afdjcj1l9p8j01dj7pv";
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [
    libbladeRF
    libusb
    ncurses
    rtl-sdr
    pkgconfig
    liquid-dsp
  ];

  prePatch = ''
    substituteInPlace cmake/Modules/FindRTLSDR.cmake --replace libs lib
    '';

  cmakeFlags = [
    "-DRTLSDR_DIR=${rtl-sdr}"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/bin $out/share $out/lib
    cp -v dump1090 view1090 $out/bin
    cp -v **/*.so **/*.so.* $out/lib
    cp -vr ../public_html $out/share/dump1090
  '';

  meta = with lib; {
    description = "A simple Mode S decoder for RTLSDR devices";
    homepage = "https://github.com/flightaware/dump1090";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ moredread ];
  };
}

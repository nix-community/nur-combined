{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, fftwFloat
, lame
, libconfig
, libshout
, pulseaudio
, rtl-sdr
, soapysdr
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtlsdr-airband";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "charlie-foxtrot";
    repo = "RTLSDR-Airband";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Dw+HyTAf33LK++71Wyrf694p1djHWT5cSkTnSga+/y8=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ fftwFloat lame libconfig libshout pulseaudio rtl-sdr soapysdr ];

  cmakeFlags = [
    (lib.cmakeBool "NFM" true)
  ];

  meta = with lib; {
    description = "Multichannel AM/NFM demodulator";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})

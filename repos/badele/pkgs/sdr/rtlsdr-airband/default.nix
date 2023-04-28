{ lib
, pkgs
, pkg-config
, stdenv
, fetchFromGitHub
, libconfig
, lame
, libshout
, librtlsdr
, soapysdr
, libpulseaudio
, fftwSinglePrec
}:

stdenv.mkDerivation rec {
  pname = "rtlsdr-airband";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "charlie-foxtrot";
    repo = "RTLSDR-Airband";
    rev = "v${version}";
    sha256 = "sha256-P/YLczlcbJFyeo/mRs17CwWZ8GbmjqP9GqTUXorr+ww=";
  };

  buildPhase = ''
    find /build
  '';

  nativeBuildInputs = with pkgs; [ cmake git pkg-config ];
  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  buildInputs = [
    libconfig
    lame
    libshout
    librtlsdr
    soapysdr
    libpulseaudio
    fftwSinglePrec
  ];

  meta = with lib; {
    description = "Multichannel AM/NFM demodulator";
    homepage = "https://github.com/charlie-foxtrot/RTLSDR-Airband";
    license = licenses.gpl3;
  };
}

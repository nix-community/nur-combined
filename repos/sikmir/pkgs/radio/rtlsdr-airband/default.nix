{ lib, stdenv, fetchFromGitHub, cmake, pkg-config
, fftwFloat, lame, libconfig, libshout, pulseaudio, rtl-sdr, soapysdr
}:

stdenv.mkDerivation rec {
  pname = "rtlsdr-airband";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "rtlsdr-airband";
    rev = "v${version}";
    hash = "sha256-KWuhffRUaCRvJgJWOBbSkqKDXtBsZ8Gln0sIp7bZqw0=";
  };

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ fftwFloat lame libconfig libshout pulseaudio rtl-sdr soapysdr ];

  cmakeFlags = [ "-DNFM=ON" ];

  meta = with lib; {
    description = "Multichannel AM/NFM demodulator";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}

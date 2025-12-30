{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  fftwFloat,
  lame,
  libconfig,
  libshout,
  pulseaudio,
  rtl-sdr,
  soapysdr,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtlsdr-airband";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "rtl-airband";
    repo = "RTLSDR-Airband";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NHxRMaOqYrjy+dQvVsRwM/+v6BC7ufPC4O93BRQ6Nuc=";
  };

  patches = [ ./find-version.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fftwFloat
    lame
    libconfig
    libshout
    pulseaudio
    rtl-sdr
    soapysdr
  ];

  cmakeFlags = [
    (lib.cmakeBool "NFM" true)
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.10")
    (lib.cmakeFeature "RTL_AIRBAND_VERSION" finalAttrs.version)
  ];

  meta = {
    description = "Multichannel AM/NFM demodulator";
    homepage = "https://github.com/rtl-airband/RTLSDR-Airband";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})

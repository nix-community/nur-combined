{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  fftwFloat,
  glib,
  libacars,
  libconfig,
  liquid-dsp,
  soapysdr,
  sqlite,
  zeromq,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dumphfdl";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "szpajder";
    repo = "dumphfdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M4WjcGA15Kp+Hpp+I2Ndcx+oBqaGxEeQLTPcSlugLwQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fftwFloat
    glib
    libacars
    libconfig
    liquid-dsp
    soapysdr
    sqlite
    zeromq
  ];

  meta = {
    description = "Multichannel HFDL decoder";
    homepage = "https://github.com/szpajder/dumphfdl";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin;
  };
})

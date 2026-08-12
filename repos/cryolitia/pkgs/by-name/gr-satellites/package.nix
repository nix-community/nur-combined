{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  gmpxx,
  gnuradio,
  feh,
  fmt,
  mpir,
  python3Packages,
  spdlog,
  volk,
  cmake,
  doxygen,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gr-satellites";
  version = "5.9.0";

  src = fetchFromGitHub {
    owner = "daniestevez";
    repo = "gr-satellites";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CZEY0mvpgpboZASJDbmu4NPyBrw4vGO1ApJAx5ozTDo=";
  };

  buildInputs = [
    boost
    gmpxx
    gnuradio
    feh
    fmt
    mpir
    python3Packages.numpy
    python3Packages.pybind11
    spdlog
    volk
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    pkg-config
  ];

  meta = {
    description = "A tool to convert PDF to HTML";
    homepage = "https://github.com/daniestevez/gr-satellites";
    license = lib.licenses.gpl3Only;
    platforms = with lib.platforms; (linux ++ darwin);
    maintainers = with lib.maintainers; [ Cryolitia ];
    mainProgram = "gr_satellites";
    # https://github.com/boostorg/boost/issues/1107
    broken = stdenv.hostPlatform.isDarwin;
  };
})

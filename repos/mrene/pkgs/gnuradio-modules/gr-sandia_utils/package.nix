{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gnuradio-boost181,
  spdlog,
  gmp,
  mpir,
  boost181,
  volk,
  gr-pdu_utils,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "gr-sandia-utils";
  version = "0-unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "gr-sandia_utils";
    rev = "e9173dcaf3d3be1b7ba8db909e1d4f88aae30848";
    hash = "sha256-xDVYVXKvzLe8jGGMrZHz0EA482cqmX+ZJEbB+3zAPys=";
  };

  patches = lib.optionals stdenv.isDarwin [
    ./compile-fixes.diff
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs =
    let
      gnuradio = gnuradio-boost181;
    in
    [
      gnuradio
      spdlog
      gmp
      mpir
      boost181
      volk
      gnuradio.python.pkgs.pybind11
      gnuradio.python.pkgs.numpy
      gr-pdu_utils
    ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "11")
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Misc blocks";
    homepage = "https://github.com/sandialabs/gr-sandia_utils";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-sandia-utils";
    platforms = platforms.unix;
  };
}

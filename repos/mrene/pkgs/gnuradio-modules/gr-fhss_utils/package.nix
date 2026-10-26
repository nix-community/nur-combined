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
  boost,
  volk,
  gr-pdu_utils,
  gr-sandia_utils,
  gr-timing_utils,
  llvmPackages,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "gr-fhss-utils";
  version = "0-unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "gr-fhss_utils";
    rev = "a2d1f5010b9b35be87ce4eabaa8e85d035d27afe";
    hash = "sha256-/byR+HJr2QK4wv+BcazAnc5JJnkK85GFzWY4z/yMjig=";
  };

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
      boost
      volk
      gnuradio.python.pkgs.pybind11
      gnuradio.python.pkgs.numpy
      gr-sandia_utils
      gr-pdu_utils
      gr-timing_utils
    ]
    ++ lib.optionals stdenv.isDarwin [ llvmPackages.openmp ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Bursty modem utilities";
    homepage = "https://github.com/sandialabs/gr-fhss_utils.git";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-fhss-utils";
    platforms = platforms.unix;
  };
}

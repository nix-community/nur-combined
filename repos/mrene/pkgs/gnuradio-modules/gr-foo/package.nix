{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, gnuradio-boost181
, spdlog
, gmp
, mpir
, boost181
, volk
}:


stdenv.mkDerivation rec {
  pname = "gr-foo";
  version = "deprecated_next_branch";

  src = fetchFromGitHub {
    owner = "bastibl";
    repo = "gr-foo";
    rev = "7c154d97f76f9c3d4ef0a8f0a659a36d3e8ecb12";
    hash = "sha256-CLVmTRe0q/D64VGdB5yqo6LmNLL1aObZPStULrx6vuQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = let 
    gnuradio = gnuradio-boost181; 
  in [
    gnuradio
    spdlog
    gmp
    mpir
    boost181
    volk
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
  ];

  meta = with lib; {
    description = "Some GNU Radio blocks that I use";
    homepage = "https://github.com/bastibl/gr-foo";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-foo";
    platforms = platforms.unix;
  };
}

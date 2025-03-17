{
  lib,
  stdenv,
  fetchFromGitHub,

  # Packages.
  boost,
  meson,
  ninja,
  perl,
  pkg-config,
  ...
}:

stdenv.mkDerivation rec {
  pname = "revbayes";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "revbayes";
    repo = "revbayes";
    rev = "v${version}";
    hash = "sha256-5zyWYrOOK8IOuBPH/6WY9VEQXdXT3X1PiGAtB4C5HJ8=";
    fetchSubmodules = true;
  };

  # Temporary hack. Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs = [
    meson
    ninja
    perl
    pkg-config
  ];
  buildInputs = [ boost ];

  preConfigure = ''
    ls -la
    (cd projects/meson/ ; ./generate.sh)
  '';

  # Use the configuration script provided by RevBayes.
  # configurePhase = ''
  #   (cd projects/meson/ ; ./generate.sh)
  #   ls
  # '';

  # buildPhase = ''
  #   meson --prefix=$out
  #   ninja install
  # '';

  # installPhase = ''
  # '';

  meta = with lib; {
    description = "Bayesian phylogenetic inference using probabilistic graphical models";
    homepage = "https://github.com/revbayes/revbayes";
    license = licenses.asl20;
    maintainers = with maintainers; [ dschrempf ];
  };
}

{ lib
, stdenv
, fetchFromGitHub

  # Packages.
, boost
, meson
, ninja
, perl
, pkg-config
, ...
}:

stdenv.mkDerivation rec {
  pname = "revbayes";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "revbayes";
    repo = "revbayes";
    rev = "${version}";
    sha256 = "09rrmq74fn0l2zzycsay1pnmdfy2zl9df2yq67gn7zw7j4y4bz06";
    fetchSubmodules = true;
  };

  # Temporary hack. Meson is no longer able to pick up Boost automatically.
  # https://github.com/NixOS/nixpkgs/issues/86131
  BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  nativeBuildInputs = [ meson ninja perl pkg-config ];
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
    description = "";
    homepage = "";
    license = licenses.asl20;
    maintainers = with maintainers; [ dschrempf ];
  };
}

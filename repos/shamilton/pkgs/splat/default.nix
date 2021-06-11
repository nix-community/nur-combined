{ lib
, stdenv
, fetchurl
, bzip2
, ncurses
, zlib
, standard_resolution_mode ? 8
, high_resolution_mode ? 8
}:
  assert 2 <= standard_resolution_mode &&
              standard_resolution_mode <= 8;
  assert 2 <= high_resolution_mode &&
              high_resolution_mode <= 8;
stdenv.mkDerivation rec {
  pname = "splat";
  version = "1.4.2";

  src = fetchurl {
    url = "https://www.qsl.net/kd2bd/splat-${version}.tar.bz2";
    sha256 = "1752b3yw8jf0ms3zj183hnx2ilggcnc4pnhy1pqbs9z9w8ab7c1r";
  };

  patches = [ ./no-interactive-configure.patch ];

  inherit standard_resolution_mode high_resolution_mode;

  postPatch = ''
    patchShebangs *
    patchShebangs utils/*
    substituteInPlace ./install \
      --replace "/usr/local" "$out"
    substituteInPlace ./utils/install \
      --replace "/usr/local" "$out"
  '';

  nativeBuildInputs = [ ncurses ];
  buildInputs = [ bzip2 zlib ];

  configureFlags = [ "-s" ];

  preInstall = ''
    mkdir -p "$out/bin"
    mkdir -p "$out/share"
    mkdir -p "$out/man/man1"
    mkdir -p "$out/man/es/man1"
  '';

  installPhase = ''
    runHook preInstall

    ./install all

    runHook postInstall
  '';

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

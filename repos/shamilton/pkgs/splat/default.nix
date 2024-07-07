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
    description = "Terrain analysis tool for the electromagnetic spectrum";
    longDescription = ''
      SPLAT! provides site engineering data such as the great circle distances
      and bearings between sites, antenna elevation angles (uptilt),
      depression angles (downtilt), antenna height above mean sea level,
      antenna height above average terrain, bearings and distances to known
      obstructions based on U.S. Geological Survey and Space Shuttle Radar
      Topography Mission elevation data, path loss and field strength based
      on the Longley-Rice Irregular Terrain as well as the new Irregular
      Terrain With Obstructions (ITWOM v3.0) model, and minimum antenna height
      requirements needed to establish line-of-sight communication paths and
      Fresnel Zone clearances absent of obstructions due to terrain.
    '';
    license = licenses.gpl2Plus;
    homepage = "https://www.qsl.net/kd2bd/splat.html";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

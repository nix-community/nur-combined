{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  unzip,
  cmake,
  zlib,
  boost,
  openssl,
  python3,
  ncurses,
  darwin,
}:

let
  version = "2.0.11";

  # Make sure we override python, so the correct version is chosen
  boostPython = boost.override {
    enablePython = true;
    python = python3;
  };

in
stdenv.mkDerivation rec {
  pname = "libtorrent-rasterbar";
  inherit version;

  src = fetchFromGitHub {
    /*
    owner = "arvidn";
    repo = "libtorrent";
    rev = "v${version}";
    hash = "sha256-iph42iFEwP+lCWNPiOJJOejISFF6iwkGLY9Qg8J4tyo=";
    */
    # fix: public ip address is not detected from loopback interface
    # https://github.com/arvidn/libtorrent/issues/7926
    # https://github.com/milahu/libtorrent/tree/use-local-interfaces
    owner = "milahu";
    repo = "libtorrent";
    rev = "refs/heads/use-local-interfaces";
    hash = "sha256-HT3Bvkox9rfzGzl+4EBL5uEgukWk7N8R46FXyvw+6SE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    unzip
    cmake
  ];

  buildInputs = [
    boostPython
    openssl
    zlib
    python3
    ncurses
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.apple_sdk.frameworks.SystemConfiguration ];

  patches = [
    # provide distutils alternative for python 3.12
    ./distutils.patch
  ];

  # https://github.com/arvidn/libtorrent/issues/6865
  postPatch = ''
    substituteInPlace cmake/Modules/GeneratePkgConfig/target-compile-settings.cmake.in \
      --replace 'set(_INSTALL_LIBDIR "@CMAKE_INSTALL_LIBDIR@")' \
                'set(_INSTALL_LIBDIR "@CMAKE_INSTALL_LIBDIR@")
                 set(_INSTALL_FULL_LIBDIR "@CMAKE_INSTALL_FULL_LIBDIR@")'
    substituteInPlace cmake/Modules/GeneratePkgConfig/pkg-config.cmake.in \
      --replace '$'{prefix}/@_INSTALL_LIBDIR@ @_INSTALL_FULL_LIBDIR@
  '';

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/${python3.libPrefix}" "$python"
  '';

  postFixup = ''
    substituteInPlace "$dev/lib/cmake/LibtorrentRasterbar/LibtorrentRasterbarTargets-release.cmake" \
      --replace "\''${_IMPORT_PREFIX}/lib" "$out/lib"
  '';

  outputs = [
    "out"
    "dev"
    "python"
  ];

  cmakeFlags = [
    "-Dpython-bindings=on"
  ];

  meta = with lib; {
    homepage = "https://libtorrent.org/";
    description = "C++ BitTorrent implementation focusing on efficiency and scalability";
    license = licenses.bsd3;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}

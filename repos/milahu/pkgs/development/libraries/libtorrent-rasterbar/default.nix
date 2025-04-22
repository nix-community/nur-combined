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

  src =
  # use fetchurl
  # https://github.com/DavHau/nix-portable/issues/148
  if true then
  fetchurl {
    url = "https://github.com/milahu/libtorrent/archive/377e4f5e482b7fe9d21ec853a9bfd2be3d29bb5c.zip";
    hash = "sha256-A2YSHVO3ASzwHVDcpumu+re7WxyvsiixnY2R0m/uPAE=";
  }
  else
  fetchFromGitHub {
/*
    owner = "arvidn";
    repo = "libtorrent";
    rev = "v${version}";
    hash = "sha256-iph42iFEwP+lCWNPiOJJOejISFF6iwkGLY9Qg8J4tyo=";
*/
    owner = "milahu";
    repo = "libtorrent";
    rev = "refs/heads/use-local-interfaces";
    hash = "sha256-HT3Bvkox9rfzGzl+4EBL5uEgukWk7N8R46FXyvw+6SE=";
    fetchSubmodules = true;
  };

  src-libsimulator = fetchurl {
    url = "https://github.com/arvidn/libsimulator/archive/aa6e074c10538f2a5ff1e8ff344e2959e08b9be7.tar.gz";
    hash = "sha256-0qFQlwSjjifGpEIbUGtZEbfR6GfeI813RXpdAav/oHo=";
  };

  src-try_signal = fetchurl {
    url = "https://github.com/arvidn/try_signal/archive/105cce59972f925a33aa6b1c3109e4cd3caf583d.tar.gz";
    hash = "sha256-bxEbDXdCmoBRvk+u0GzyP7A89u4jOWfIT92djTtCuo4=";
  };

  src-asio-gnutls = fetchurl {
    url = "https://github.com/paullouisageneau/boost-asio-gnutls/archive/a57d4d36923c5fafa9698e14be16b8bc2913700a.tar.gz";
    hash = "sha256-hlohJW3giUW3nr3GYnDxCvuSimOOLBgp55SMWXbyidU=";
  };

  postUnpack = ''
    pushd $sourceRoot

    mkdir -p simulation/libsimulator
    tar -C simulation/libsimulator -x -f ${src-libsimulator} --strip-components=1

    mkdir -p deps/try_signal
    tar -C deps/try_signal -x -f ${src-try_signal} --strip-components=1

    mkdir -p deps/asio-gnutls
    tar -C deps/asio-gnutls -x -f ${src-asio-gnutls} --strip-components=1

    popd
  '';

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

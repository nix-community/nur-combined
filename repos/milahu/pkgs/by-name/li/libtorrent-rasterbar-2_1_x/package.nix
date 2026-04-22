{
  lib,
  stdenv,
  boost,
  fetchFromGitHub,
  cmake,
  openssl,
  boringssl,
  python3,
}:

let
  # Make sure we override python, so the correct version is chosen
  boostPython = boost.override {
    enablePython = true;
    python = python3;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libtorrent-rasterbar";
  version = "2.1.0-pre-2026-03-28";

  src = fetchFromGitHub {
    owner = "arvidn";
    repo = "libtorrent";
    # there are no tags for version 2.1 yet
    # tag = "v${finalAttrs.version}";
    rev = "aa59c7c583e00e7b91f324d0792279d4637ab899";
    fetchSubmodules = true;
    hash = "sha256-5K9+TnGYbbVx2FAXyUp71QPRWMe3HMYAIZVCS936QOM=";
  };

  nativeBuildInputs = [
    cmake
    python3
  ];

  buildInputs = [
    boostPython
    # https://github.com/arvidn/libtorrent/issues/7529#issuecomment-1811610101
    # ECH (Encrypted Client Hello) support for HTTPS trackers
    openssl
    # FIXME this breaks with https trackers:
    # CERTIFICATE_VERIFY_FAILED (SSL routines, OPENSSL_internal)
    # boringssl
  ];

  strictDeps = true;

  patches = [
    # 1 out of 1 hunk FAILED -- saving rejects to file bindings/python/CMakeLists.txt.rej
    # # provide distutils alternative for python 3.12
    # ./distutils.patch
  ];

  # https://github.com/arvidn/libtorrent/issues/6865
  postPatch = ''
    substituteInPlace cmake/Modules/GeneratePkgConfig/target-compile-settings.cmake.in \
      --replace-fail \
        'set(_INSTALL_LIBDIR "@CMAKE_INSTALL_LIBDIR@")' \
        'set(_INSTALL_LIBDIR "@CMAKE_INSTALL_LIBDIR@")
         set(_INSTALL_FULL_LIBDIR "@CMAKE_INSTALL_FULL_LIBDIR@")'
  ''
  # a: libdir=''${prefix}//nix/store/...
  # b: libdir=/nix/store/...
  # https://github.com/NixOS/nixpkgs/issues/144170
  + ''
    substituteInPlace cmake/Modules/GeneratePkgConfig/pkg-config.cmake.in \
      --replace-fail '$'{prefix}/@_INSTALL_LIBDIR@ @_INSTALL_FULL_LIBDIR@
  '';
  /*
    # fix: Installing: $out/$out/lib/pkgconfig/libtorrent-rasterbar.pc
    substituteInPlace cmake/Modules/GeneratePkgConfig/generate-pkg-config.cmake.in \
      --replace-fail "\''${CMAKE_INSTALL_PREFIX}/@CMAKE_INSTALL_LIBDIR@/pkgconfig" "$dev/lib/pkgconfig"
  */

  postInstall = ''
    moveToOutput "include" "$dev"
    moveToOutput "lib/${python3.libPrefix}" "$python"
  '';

  postFixup = ''
    substituteInPlace $dev/lib/cmake/LibtorrentRasterbar/LibtorrentRasterbarTargets-*.cmake \
      --replace-fail "\''${_IMPORT_PREFIX}/lib" "$out/lib"
  ''
  # a: Cflags: ... -I/nix/store/x//nix/store/x-dev/include ...
  # b: Cflags: ... -I/nix/store/x-dev/include ...
  + ''
    substituteInPlace $dev/lib/pkgconfig/libtorrent-rasterbar.pc \
      --replace-fail "$out/$dev" "$dev"
  '';

  outputs = [
    "out"
    "dev"
    "python"
  ];

  cmakeFlags = [
    (lib.cmakeBool "python-bindings" true)
  ];

  meta = {
    homepage = "https://libtorrent.org/";
    description = "Efficient feature complete C++ bittorrent implementation";
    changelog = "https://github.com/arvidn/libtorrent/blob/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})

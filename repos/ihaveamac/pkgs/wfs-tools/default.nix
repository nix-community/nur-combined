# TODO: remove stdenv override when 24.11 goes eol
{
  lib,
  stdenv,
  clang19Stdenv,
  gcc14Stdenv,
  callPackage,
  fetchFromGitHub,
  pkg-config,
  cmake,
  boost,
  cryptopp,
  fuse,
  withFUSE ? !stdenv.hostPlatform.isWindows,
}:

let
  realStdenv = if stdenv.cc.isClang then clang19Stdenv else gcc14Stdenv;
  realCryptopp =
    if stdenv.hostPlatform.isWindows then
      (cryptopp.overrideAttrs (
        final: prev:
        lib.warn "overriding" {
          postPatch =
            prev.postPatch
            + ''
              substituteInPlace GNUmakefile \
                --replace _WIN32_WINNT=0x0501 _WIN32_WINNT=0x0601
            '';
        }
      ))
    else
      cryptopp;
in
realStdenv.mkDerivation rec {
  pname = "wfs-tools";
  version = "1.2.3-unstable-2025-03-01";

  src = fetchFromGitHub {
    owner = "koolkdev";
    repo = pname;
    rev = "3ec70a97b32ce37e59f1c477e9db98f4b0c2ddc6";
    hash = "sha256-cB4xQEGRmDzWdEKwhyK5NRLZsYPtq50kFHLfXHxFSqE=";
  };

  passthru.wfslib = fetchFromGitHub {
    owner = "koolkdev";
    repo = "wfslib";
    rev = "4f95c825cc1b406d2df848ab5cb971f80fa0c3d5";
    hash = "sha256-WhwtgnMQ8Ba6XN38kW0R7pQ93yI6Pxm5A73CIryQ0BM=";
  };

  patches = [
    ./wfslib-use-pkg-config-for-cryptopp.patch
    ./remove-fuse-check.patch
  ] ++ lib.optional (!withFUSE) ./remove-wfs-fuse.patch;

  prePatch = ''
    rmdir wfslib
    cp -r ${passthru.wfslib} wfslib
    chmod -R u+w ./wfslib
  '';

  cmakeFlags = lib.optionals withFUSE (
    if realStdenv.isDarwin then
      [
        (lib.cmakeFeature "FUSE_INCLUDE_DIR" "${fuse}/include")
        (lib.cmakeFeature "FUSE_LIBRARIES" "/usr/local/lib/libfuse.2.dylib")
      ]
    else
      [
        (lib.cmakeFeature "FUSE_INCLUDE_DIR" "${fuse.dev}/include")
        (lib.cmakeFeature "FUSE_LIBRARIES" "${fuse.out}/lib/libfuse${stdenv.hostPlatform.extensions.library}")
      ]
  );

  installPhase = ''
    mkdir -p $out/bin
    for f in wfs-extract wfs-file-injector wfs-info wfs-reencryptor ${lib.optionalString withFUSE "wfs-fuse"}; do
      cp -v $f/$f $out/bin
    done
  '';

  buildInputs = [
    boost
    realCryptopp
  ] ++ lib.optional withFUSE fuse;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  meta = with lib; {
    description = "WFS (WiiU File System) Tools";
    homepage = "https://github.com/koolkdev/wfs-tools";
    license = licenses.mit;
    platforms = platforms.all;
    # boost fails due to "dlfcn.h" missing or something
    broken = stdenv.hostPlatform.isWindows;
  };
}

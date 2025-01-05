# TODO: remove stdenv override when 24.11 goes eol
{ lib, stdenv, clang19Stdenv, gcc14Stdenv, callPackage, fetchFromGitHub, pkg-config, cmake, boost, cryptopp, fuse }:

let
  realStdenv = if stdenv.cc.isClang then clang19Stdenv else gcc14Stdenv;
  wfslib = fetchFromGitHub {
    owner = "koolkdev";
    repo = "wfslib";
    rev = "fb4fd2b1fd16276b62438661fc6992f781d8e394";
    hash = "sha256-WwBQMzPosh57urL09zFyuR5BZcnOAwD2sLh9M9WHFeQ=";
  };
in
realStdenv.mkDerivation rec {
  pname = "wfs-tools";
  version = "1.2.3-unstable-2024-12-06";

  src = fetchFromGitHub {
    owner = "koolkdev";
    repo = pname;
    rev = "366ad010447c8598435ee3fc56ab0c891aed33cb";
    hash = "sha256-0z8flmWgVjFMSfqyXNVeNYvuGm8wuR6iwVp5D3pM44Y=";
  };

  patches = [
    ./wfslib-use-pkg-config-for-cryptopp.patch
    ./remove-fuse-check.patch
  ];

  prePatch = ''
    rmdir wfslib
    cp -r ${wfslib} wfslib
    chmod -R u+w ./wfslib
  '';

  cmakeFlags = (if realStdenv.isDarwin then [
    (lib.cmakeFeature "FUSE_INCLUDE_DIR" "${fuse}/include")
    (lib.cmakeFeature "FUSE_LIBRARIES" "/usr/local/lib/libfuse.2.dylib")
  ] else [
    (lib.cmakeFeature "FUSE_INCLUDE_DIR" "${fuse.dev}/include")
    (lib.cmakeFeature "FUSE_LIBRARIES" "${fuse.out}/lib/libfuse.so")
  ]);

  installPhase = ''
    mkdir -p $out/bin
    for f in wfs-extract wfs-file-injector wfs-fuse wfs-info wfs-reencryptor; do
      cp -v $f/$f $out/bin
    done
  '';

  buildInputs = [ boost cryptopp fuse ];

  nativeBuildInputs = [ cmake pkg-config ];

  meta = with lib; {
    description = "WFS (WiiU File System) Tools";
    homepage = "https://github.com/koolkdev/wfs-tools";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

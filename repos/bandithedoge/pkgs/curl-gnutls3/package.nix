{
  fetchFromGitHub,
  lib,
  stdenv,

  autoreconfHook,
  gnutls,
  nghttp2,
  perl,
  pkg-config,
  zlib,
}:
stdenv.mkDerivation {
  pname = "curl";
  version = "8.4.0";
  src = fetchFromGitHub {
    owner = "curl";
    repo = "curl";
    rev = "curl-8_4_0";
    hash = "sha256-2sAnQKWk67MNR2pFQGDN1mQ6re+A9we3oPkM6bZAmYw=";
  };

  patches = [ ./03_keep_symbols_compat.patch ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    perl
  ];

  propagatedBuildInputs = [
    gnutls
    nghttp2
    zlib
  ];

  postInstall =
    let
      inherit (stdenv.hostPlatform.extensions) sharedLibrary;
    in
    ''
      ln $out/lib/libcurl${sharedLibrary} $out/lib/libcurl-gnutls${sharedLibrary}
      ln $out/lib/libcurl${sharedLibrary} $out/lib/libcurl-gnutls${sharedLibrary}.4
      ln $out/lib/libcurl${sharedLibrary} $out/lib/libcurl-gnutls${sharedLibrary}.4.4.0
    '';

  enableParallelBuilding = true;

  configureFlags = [
    "--disable-manual"
    "--with-gnutls"
  ];

  meta = {
    description = "libcurl with libcurl3 symbols";
    homepage = "https://curl.se";
    license = lib.licenses.curl;
    platforms = lib.platforms.linux;
    mainProgram = "curl";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}

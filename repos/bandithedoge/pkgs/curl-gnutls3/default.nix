{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "curl";
  version = "8.4.0";
  src = pkgs.fetchFromGitHub {
    owner = "curl";
    repo = "curl";
    rev = "curl-8_4_0";
    hash = "sha256-2sAnQKWk67MNR2pFQGDN1mQ6re+A9we3oPkM6bZAmYw=";
  };

  patches = [./03_keep_symbols_compat.patch];

  nativeBuildInputs = with pkgs; [
    pkg-config
    autoreconfHook
    perl
  ];

  propagatedBuildInputs = with pkgs; [
    gnutls
    nghttp2
    zlib
  ];

  postInstall = let
    inherit (pkgs.stdenv.hostPlatform.extensions) sharedLibrary;
  in ''
    ln $out/lib/libcurl${sharedLibrary} $out/lib/libcurl-gnutls${sharedLibrary}
    ln $out/lib/libcurl${sharedLibrary} $out/lib/libcurl-gnutls${sharedLibrary}.4
    ln $out/lib/libcurl${sharedLibrary} $out/lib/libcurl-gnutls${sharedLibrary}.4.4.0
  '';

  enableParallelBuilding = true;

  configureFlags = [
    "--disable-manual"
    "--with-gnutls"
  ];

  meta = with pkgs.lib; {
    description = "libcurl with libcurl3 symbols";
    homepage = "https://curl.se";
    license = licenses.curl;
    platforms = platforms.linux;
  };
}

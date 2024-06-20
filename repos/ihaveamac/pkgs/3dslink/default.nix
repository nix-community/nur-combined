{ fetchFromGitHub, stdenv, lib, autoconf, automake, pkg-config, zlib }:

stdenv.mkDerivation rec {
  pname = "3dslink";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-XygsHIdfFpNnVLKO3r5QE+ALlX5DrxqKwkenuwgiIwA=";
  };

  preConfigure = ''
    ./autogen.sh
  '';

  sourceRoot = "source/host";
  
  buildInputs = [ zlib ];
  nativeBuildInputs = [ autoconf automake pkg-config ];

  meta = with lib; {
    description = "Send 3DSX files to the Homebrew Launcher on 3DS";
    homepage = "https://github.com/devkitPro/3dslink";
    platforms = platforms.all;
  };
}

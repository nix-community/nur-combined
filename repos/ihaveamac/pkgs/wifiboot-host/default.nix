{
  fetchFromGitHub,
  stdenv,
  lib,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "wifiboot-host";
  version = "unstable-2023-07-02";

  src = fetchFromGitHub {
    owner = "danny8376";
    repo = pname;
    rev = "d606c348740d40842d1282abc2fc91948bb31e41";
    hash = "sha256-jNyYpPs6MgBc19PoWIH+DnCVrOYYyJLtM7K2MsuiywM=";
  };

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
    "AR=${stdenv.cc.targetPrefix}ar"
    "OBJCOPY=${stdenv.cc.targetPrefix}objcopy"
  ]
  ++ (lib.optional stdenv.hostPlatform.isMinGW "PLATFORM_LIBS=-lws2_32");

  installPhase = ''
    mkdir -p $out/bin
    cp wifiboot${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "command line version uploader for https://problemkaputt.de/wifiboot.htm";
    homepage = "https://github.com/danny8376/wifiboot-host";
    platforms = platforms.all;
    mainProgram = "wifiboot";
  };
}

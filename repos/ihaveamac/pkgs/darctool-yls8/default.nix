{
  lib,
  stdenv,
  libiconvReal,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "darctool-yls8";
  version = "0-unstable-2015-11-21";

  src = fetchFromGitHub {
    owner = "yellows8";
    repo = "darctool";
    rev = "724a985b66faa8c8033f0005e0662975faf75068";
    hash = "sha256-hxd76RejpVs/le1KT5jqZYXYr66FBeierYaeRR5opDc=";
  };

  buildInputs = [ libiconvReal ];

  buildPhase = ''
    ${stdenv.cc.targetPrefix}cc -o darctool darctool.c utils.c -liconv
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp darctool${stdenv.hostPlatform.extensions.executable} $out/bin
  '';

  meta = with lib; {
    description = "Tool for extracting and building 3DS darc archive files.";
    homepage = "https://github.com/yellows8/darctool";
    platforms = platforms.all;
    mainProgram = "darctool";
  };
}

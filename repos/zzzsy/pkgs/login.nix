{
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "bh-login";
  version = "0.1.1";

  src = fetchurl {
    url = "https://github.com/buaahub/beihang-login-rs/releases/download/v${version}/beihang-login-Linux-musl-x86_64.tar.gz";
    hash = "sha256-Nhhh0xx0SQy0LZ1kuHlwWoByg5gDFRJ3zG/kkKf7beA=";
  };

  sourceRoot = ".";

  installPhase = ''
    install -m755 -D beihang-login $out/bin/bh-login
  '';
}

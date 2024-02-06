{ lib, stdenvNoCC, fetchzip }:
stdenvNoCC.mkDerivation rec {
  pname = "morisawa-biz-ud-gothic";
  version = "1.05";

  src = fetchzip {
    url =
      "https://github.com/googlefonts/morisawa-biz-ud-gothic/releases/download/v${version}/morisawa-biz-ud-gothic-fonts.zip";
    sha256 = "sha256-iBxSmW30i2BfqRBLMUDlMKu6nRk6qyc7yreSQYIibzo=";
  };

  installPhase = ''
    install -D -m 444 fonts/ttf/* -t $out/share/fonts/truetype/${pname}
  '';
}

{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "teldrive";
  version = "1.8.3";

  src = fetchurl {
    url = "https://github.com/tgdrive/teldrive/releases/download/${version}/teldrive-${version}-linux-amd64.tar.gz";
    hash = "sha256:4114362c9bedad59df1f01642d7268dc73b63ac2dd9970a957c7d0c0ea70d0a4"; 
  };

  # Biasanya rilis biner Go langsung diekstrak di root, bukan di dalam folder.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 teldrive $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Telegram Drive - Telegram as a cloud storage";
    homepage = "https://github.com/tgdrive/teldrive";
    platforms = [ "x86_64-linux" ];
  };
}

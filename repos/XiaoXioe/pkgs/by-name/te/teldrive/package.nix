{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "teldrive";
  version = "2.0.6";

  src = fetchurl {
    url = "https://github.com/tgdrive/teldrive/releases/download/${version}/teldrive-${version}-linux-amd64.tar.gz";
    hash = "sha256-bvHJE6wNbOLW900tG+aI3TljMbxDOk5KDTfGu5IcVQk=";
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
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}

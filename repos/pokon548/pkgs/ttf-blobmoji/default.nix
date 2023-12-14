{ lib
, stdenv
, fetchurl
}:
stdenv.mkDerivation rec {
  pname = "ttf-blobmoji";
  version = "15.0";

  src = fetchurl {
    url = "https://github.com/C1710/blobmoji/releases/download/v${version}/Blobmoji.ttf";
    hash = "sha256-3MPWZ1A2ups171dNIiFTJ3C1vZiGy6I8ZF70aUfrePk=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D $src $out/share/fonts/truetype/Blobmoji.ttf

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/C1710/blobmoji";
    description = "Noto Emoji with extended Blob support";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ pokon548 ];
  };
}
{ stdenv
, fetchurl
, lib
, unzip
, jre_headless
, makeWrapper
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "hath";
  version = "1.6.1";
  src = fetchurl {
    url = "https://repo.e-hentai.org/hath/HentaiAtHome_${version}.zip";
    sha256 = "sha256-uIibLDVZMAS+BhBk/LbWkP+MvalWTYn3Bvfjzq+ChyY=";
  };

  nativeBuildInputs = [ unzip makeWrapper ];

  unpackPhase = ''
    unzip ${src}
  '';

  installPhase = ''
    mkdir -p $out/bin $out/opt
    cp HentaiAtHome.jar $out/opt/

    makeWrapper ${jre_headless}/bin/java $out/bin/hath \
      --add-flags "-Xms16m" \
      --add-flags "-Xmx512m" \
      --add-flags "-jar" \
      --add-flags "$out/opt/HentaiAtHome.jar" \
  '';

  meta = with lib; {
    description = "Hentai@Home";
    homepage = "https://e-hentai.org/";
    license = licenses.gpl3;
  };
}

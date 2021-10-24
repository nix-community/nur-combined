{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "gpx-animator";
  version = "1.7.0";

  src = fetchurl {
    url = "https://download.gpx-animator.app/gpx-animator-${version}-all.jar";
    hash = "sha256-SiYaHFMHKbEA8whio3MeCq8QZ6bQGWU4i/ok8I28TpA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    install -Dm644 $src $out/share/java/${src.name}

    makeWrapper ${jre}/bin/java $out/bin/gpx-animator \
      --add-flags "-jar $out/share/java/gpx-animator-${version}-all.jar"
  '';

  meta = with lib; {
    description = "GPX Animator";
    homepage = "https://gpx-animator.app/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
}

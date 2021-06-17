{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "gpx-animator";
  version = "1.6.1";

  src = fetchurl {
    url = "https://download.gpx-animator.app/gpx-animator-${version}-all.jar";
    hash = "sha256-f99lz8EtAZnQB2BE773oiISHrqGfgsG/mCvFnd1Xrtc=";
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
    platforms = platforms.unix;
    skip.ci = true;
  };
}

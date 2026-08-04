{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeDesktopItem,
  copyDesktopItems,
  jdk,
  jre,
  makeWrapper,
  stripJavaArchivesHook,
}:

stdenv.mkDerivation rec {
  pname = "knotjob";
  version = "0-chartreuse-2026-02-12";

  src = fetchurl {
    url = "https://www.maths.dur.ac.uk/users/dirk.schuetz/KnotJob.zip";
    hash = "sha256-kIlr8W0y2vqFLvUIN7wcu2MqFxsKP9aClhoI8usjiJw=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    unzip
    stripJavaArchivesHook
    jdk
    copyDesktopItems
    makeWrapper
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "KnotJob";
      exec = "KnotJob";
    })
  ];

  postPatch = ''
    substituteInPlace knotjob/frames/ViewDocumentation.java \
      --replace-fail '"Documentation"' '"${placeholder "doc"}/share/doc/KnotJob"'
  '';

  buildPhase = ''
    runHook preBuild

    javac knotjob/KnotJob.java
    jar -c -f KnotJob.jar -e knotjob.KnotJob -C . knotjob

    for f in Knots/*.txt.zip; do
      unzip "$f" -d Knots
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 KnotJob.jar $out/share/java/KnotJob.jar

    for f in Knots/*.{txt,kjb}; do
      install -Dm644 -t "$out/share/KnotJob" "$f"
    done

    mkdir -p $out/bin

    makeWrapper ${jre}/bin/java $out/bin/KnotJob \
      --prefix _JAVA_OPTIONS " " -Dawt.useSystemAAFontSettings=lcd \
      --add-flags "-jar $out/share/java/KnotJob.jar"

    for f in Documentation/*.rtf; do
      install -Dm644 -t "$doc/share/doc/KnotJob" "$f"
    done

    runHook postInstall
  '';

  meta = {
    description = "Calculate knot invariants, centered around Khovanov homology";
    license = lib.licenses.gpl3;
    homepage = "https://www.maths.dur.ac.uk/users/dirk.schuetz/knotjob.html";
    mainProgram = "KnotJob";
    platforms = lib.platforms.linux;
  };
}

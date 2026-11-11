{
  lib,
  fetchzip,
  unzip,
  stdenvNoCC,
  jdk,
  jre,
  stripJavaArchivesHook,
  makeWrapper,
  makeDesktopItem ,
  copyDesktopItems,
}:

stdenvNoCC.mkDerivation {
  pname = "knotjob";
  version = "2026-02-12-chartreuse";

  src = fetchzip {
    url = "https://www.maths.dur.ac.uk/users/dirk.schuetz/KnotJob.zip";
    hash = "sha256-91VyG+mITz/3E3mI7z12++ekgGkA0pfCvXCx8FDEqOg=";
  };

  patches = [
    ./relative-paths.patch
  ];

  postPatch = ''
    substituteInPlace knotjob/{KnotJobCommand.java,Options.java,frames/ViewDocumentation.java} \
      --subst-var out
  '';

  nativeBuildInputs = [
    unzip
    jdk
    stripJavaArchivesHook
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name        = "KnotJob";
      desktopName = "KnotJob";
      exec        = "KnotJob";
      icon        = "KnotJob";
    })
  ];

  buildPhase = ''
    runHook preBuild

    javac -d build $(find knotjob -name '*.java')
    jar --create --file KnotJob.jar --main-class knotjob.KnotJob -C build .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    export kjb="$out"/share/KnotJob
    mkdir -p "$kjb"

    install -Dm644 -t "$kjb" \
      README.TXT  \
      KnotJob.jar \
      knotjob.png \
      knotjob_med.png

    makeWrapper ${jre}/bin/java "$out"/bin/KnotJob \
      --add-flags "-jar $kjb/KnotJob.jar" \
      --prefix _JAVA_OPTIONS " " "-Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel" \
      --prefix _JAVA_OPTIONS " " "-Dawt.useSystemAAFontSettings=gasp"

    unzip -q "Knots/*.txt.zip" -d Knots

    install -Dm644 -t "$kjb"/Knots \
      Knots/*.kjb \
      Knots/*.txt

    install -Dm644 -t "$kjb"/Documentation \
      Documentation/*.rtf

    mkdir -p "$out"/share/icons/hicolor/96x96/apps
    ln -s "$kjb"/knotjob_med.png "$out"/share/icons/hicolor/96x96/apps/KnotJob.png

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    "$out"/bin/KnotJob -h
    "$out"/bin/KnotJob "$out"/share/KnotJob/Knots/Rolfsen.kjb -s0 -nf

    runHook postInstallCheck
  '';

  meta = {
    description = "Calculate knot invariants, centered around Khovanov homology";
    license = lib.licenses.gpl3Plus;
    homepage = "https://www.maths.dur.ac.uk/users/dirk.schuetz/knotjob.html";
    mainProgram = "KnotJob";
    platforms = lib.platforms.linux;
  };
}

{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  makeWrapper,
  stripJavaArchivesHook,
  ant,
  jdk,
  jre8,
}:

let
  log4j = fetchzip {
    url = "https://archive.apache.org/dist/logging/log4j/1.2.17/log4j-1.2.17.zip";
    hash = "sha256-pZkTn0hADOGb3DCAQpMp8dXh7WZLuwiEIgVjluPzbD0=";
  };
in
stdenv.mkDerivation {
  pname = "riscVivid";
  version = "1.4";

  meta = {
    description = "A RISC-V processor simulator";
    homepage = "https://github.com/unia-sik/riscVivid";
    license = lib.licenses.gpl3Plus;
    mainProgram = "riscVivid";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource lib.sourceTypes.binaryBytecode ];
  };

  src = fetchFromGitHub {
    owner = "unia-sik";
    repo = "riscVivid";
    rev = "bff823c257c75bb57d9ef1e63ecca741f10b60a4";
    hash = "sha256-1YWOnoybhF5ybNzV7Hge/A6y+7c0RhYBH209bgF8iLk=";
  };

  patches = [
    ./01-change-java-version.patch
    ./02-copy-whole-image-directory.patch
  ];

  nativeBuildInputs = [
    ant
    jdk
    stripJavaArchivesHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    rm -rf lib_local/apache-log4j-1.2.17
    ln -s ${log4j} lib_local/apache-log4j-1.2.17

    ant build_and_package

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 riscVivid.jar $out/share/java/riscVivid.jar

    mkdir -p $out/bin
    makeWrapper ${jre8}/bin/java $out/bin/riscVivid \
      --add-flags "-jar $out/share/java/riscVivid.jar"

    install -Dm644 img/riscVivid-quadrat128x128.png $out/share/icons/riscVivid.png
    install -Dm644 ${./riscVivid.desktop} $out/share/applications/riscVivid.desktop

    runHook postInstall
  '';
}

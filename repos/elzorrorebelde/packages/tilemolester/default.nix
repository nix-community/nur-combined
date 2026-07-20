##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  lib,
  maven,
  fetchFromGitHub,
  makeWrapper,
  jre,
}:

maven.buildMavenPackage rec {
  pname = "tilemolester";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "toruzz";
    repo = "TileMolester";
    rev = "v${version}";
    hash = "sha256-1YSpN2m5DA5VLrCQ/xRP1XIVV7oGaUsrDOCYAzvh2BE=";
  };

  mvnHash = "sha256-5Gv9s5WeGoGe2z9cxK3I8N00SdEAfgrLOUPDNAX5ka4=";

  patches = [
    ./patches/0001-XMLParser-add-InputStream-parse.patch
    ./patches/0002-TMSpecReader-add-readSpecs.patch
    ./patches/0003-TMUI-use-readSpecs.patch
    ./patches/0004-TMSettings-classpath-resources.patch
  ];

  prePatch = ''
    # Upstream source uses CRLF line endings; patch expects LF
    find . -name '*.java' -exec sed -i 's/\r$//' {} +
  '';

  postPatch = ''
    # Bundle XML files and their DTDs in the JAR so they can be loaded from classpath
    cp tmspec.xml src/main/resources/
    cp tmspec.dtd src/main/resources/
    cp settings.dtd src/main/resources/
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/tilemolester
    cp target/tilemolester.jar $out/share/tilemolester/

    makeWrapper ${jre}/bin/java $out/bin/tilemolester \
      --add-flags "-jar $out/share/tilemolester/tilemolester.jar"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Multi-format, user-extensible graphics data editor for arbitrary binary files";
    longDescription = ''
      Tile Molester is a multi-format, user-extensible graphics data editor
      that lets you create, view and edit graphics in arbitrary binary files,
      with a particular focus on binaries for game consoles.
    '';
    homepage = "https://github.com/toruzz/TileMolester";
    changelog = "https://github.com/toruzz/TileMolester/releases";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "tilemolester";
  };
}

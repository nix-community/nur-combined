{
  lib,
  autoPatchelfHook,
  fetchFromGitLab,
  libX11,
  libXrandr,
  libXcursor,
  libXi,
  libXxf86vm,
  libXrender,
  libdrm,
  libgbm,
  jre,
  makeWrapper,
  maven,
  unzip,
  zip,
}:

maven.buildMavenPackage rec {
  pname = "jerboa-studio";
  version = "0-unstable-2025-09-04";

  src = fetchFromGitLab {
    owner = "JerboaTeam";
    repo = "jerboa-studio";
    rev = "0dcccec2e86b3a32da74ab0c7e40f421344ee4cd";
    hash = "sha256-XZtSv8PdN2VJdDvAwY/zrk5DAIKdPL7+B6W13Pq4zw8=";
  };

  mvnHash = "sha256-22mklcf4pcjv9xLl2H4ItRmaho/ger0cx4Q7amQd1Ug=";
  mvnParameters = "-P release";

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    unzip
    zip
  ];

  buildInputs = [
    libX11
    libXrandr
    libXcursor
    libXi
    libXxf86vm
    libXrender
    libdrm
    libgbm
  ];

  dontAutoPatchelf = true;

  postPatch = ''
    substituteInPlace src/main/java/fr/up/xlim/ig/jerboa/studio/JerboaStudio.java \
      --replace-fail '"JerboaModelerStudio.jme"' '"${placeholder "out"}/share/jerboa-studio/JerboaModelerStudio.jme"'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/share/jerboa-studio

    here=$(pwd)
    extract=$(mktemp -d)
    unzip ./target/jerboa-studio-1.0.5-SNAPSHOT-jar-with-dependencies.jar 'natives/linux-amd64/*' -d $extract
    addAutoPatchelfSearchPath ${jre}/lib/openjdk/lib
    autoPatchelf $extract/natives/linux-amd64
    #pushd $extract
    #zip -r $here/target/jerboa-studio-1.0.5-SNAPSHOT-jar-with-dependencies.jar natives/linux-amd64
    #popd
    mv $extract/natives/linux-amd64/* $out/lib/

    install -Dm644 ./target/jerboa-studio-1.0.5-SNAPSHOT-jar-with-dependencies.jar $out/share/jerboa-studio
    cp $src/JerboaModelerStudio.jme $out/share/jerboa-studio

    makeWrapper ${lib.getExe jre} $out/bin/jerboa-studio \
      --set LD_LIBRARY_PATH $out/lib \
      --add-flags "-jar $out/share/jerboa-studio/jerboa-studio-1.0.5-SNAPSHOT-jar-with-dependencies.jar"

    runHook postInstall
  '';

  meta = {
    description = "Simple command line wrapper around JD Core Java Decompiler project";
    homepage = "https://github.com/intoolswetrust/jd-cli";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ majiir ];
  };
}
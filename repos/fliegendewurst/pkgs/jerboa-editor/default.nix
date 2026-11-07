{
  lib,
  fetchFromGitLab,
  jre,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "jerboa-editor";
  version = "2.1.6";

  src = fetchFromGitLab {
    owner = "JerboaTeam";
    repo = "jerboa-editor";
    tag = "2.1.6";
    hash = "sha256-7QvyozLZNmuh7KyUW8Juw49EYD81FAkte+cvGxLx59M=";
  };

  preferLocalBuild = true;

  mvnHash = "sha256-U1AyGreyw6QGWp5IOoUh3liVz461a9ISQUMaQv78tGQ=";
  mvnParameters = "-P release";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/jerboa-editor
    install -Dm644 ./target/jerboa-editor-${version}-SNAPSHOT-jar-with-dependencies.jar $out/share/jerboa-editor

    makeWrapper ${lib.getExe jre} $out/bin/jerboa-editor \
      --add-flags "-jar $out/share/jerboa-editor/jerboa-editor-${version}-SNAPSHOT-jar-with-dependencies.jar"

    runHook postInstall
  '';

  meta = {
    description = "Simple command line wrapper around JD Core Java Decompiler project";
    homepage = "https://github.com/intoolswetrust/jd-cli";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ majiir ];
  };
}
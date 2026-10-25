{
  lib,
  biome,
  buildNpmPackage,
  fetchFromGitHub,
  maven,
  nixosTests,
  writeText,
  mandrel,
  removeReferencesTo,
  makeWrapper,
  glibc,
}:
let
  binaryVersion = "7.4.1";
  version = "982476b2d007163e48e2c99d8b55f5dc91acc704";
  # version = binaryVersion;
  db = "h2";

  src = fetchFromGitHub {
    owner = "Athou";
    repo = "commafeed";
    rev = version;
    hash = "sha256-sK69HZ4ztkIrVqwrnQ9S7OSYZ99tae9nGAQpUwWMZ5c=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "commafeed-frontend";

    sourceRoot = "${src.name}/commafeed-client";

    npmDepsHash = "sha256-rY9Blj8v28wtKJgjoMEw3JdDIC4rq6my4sJgVIujsKs=";

    nativeBuildInputs = [ biome ];

    installPhase = ''
      runHook preInstall

      cp -r dist/ $out

      runHook postInstall
    '';
  };

  gitProperties = writeText "git.properties" ''
    git.branch = none
    git.build.time = 1970-01-01T00:00:00+0000
    git.build.version = ${version}
    git.commit.id = none
    git.commit.id.abbrev = none
  '';
in
maven.buildMavenPackage {
  inherit version src db;

  pname = "commafeed";

  mvnJdk = mandrel;
  mvnHash = "sha256-IW79qSoGcXg/6NJf3U4jjWxIwpF46eMr9D3A6APAU9Q=";

  mvnParameters = lib.escapeShellArgs [
    "-Pnative"
    "-P${db}"
    "-DskipTests"
    "-Dskip.installnodenpm"
    "-Dskip.npm"
    "-Dspotless.check.skip"
    "-Dmaven.gitcommitid.skip"
  ];

  mvnDepsParameters = lib.escapeShellArgs [
  ];

  configurePhase = ''
    runHook preConfigure

    ln -sf "${frontend}" commafeed-client/dist

    cp ${gitProperties} commafeed-server/src/main/resources/git.properties

    runHook postConfigure
  '';

  nativeBuildInputs = [ makeWrapper ];

  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share

    cp commafeed-server/target/quarkus-generated-doc/application.properties \
      $out/share/application.properties

    install -Dm755 commafeed-server/target/commafeed-${binaryVersion}-${db}-linux-x86_64-runner \
      $out/bin/commafeed

    wrapProgram $out/bin/commafeed --prefix PATH : ${lib.makeBinPath [ glibc ]}
      
    runHook postInstall
  '';

  disallowedReferences = [
    mandrel
    maven
  ];

  postInstall = ''
    find "$out" -type f -exec ${lib.getExe removeReferencesTo} -t ${mandrel} -t ${maven} '{}' +
    echo >> $out/share/application.properties
    echo "# Create database in current working directory" >> $out/share/application.properties
    echo "quarkus.datasource.jdbc.url=jdbc:h2:./database/db;DEFRAG_ALWAYS=TRUE" >> $out/share/application.properties
  '';

  passthru.tests = nixosTests.commafeed;

  meta = {
    description = "Google Reader inspired self-hosted RSS reader";
    homepage = "https://github.com/Athou/commafeed";
    license = lib.licenses.asl20;
    mainProgram = "commafeed";
  };
}

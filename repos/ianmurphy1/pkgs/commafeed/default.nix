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
  binaryVersion = "7.4.0";
  # version = "fc56d5e7cbe9c8a0b13af3969d277b0f10ba841a";
  version = binaryVersion;
  db = "h2";

  src = fetchFromGitHub {
    owner = "Athou";
    repo = "commafeed";
    rev = version;
    hash = "sha256-YAXuDBnERp1rw3uoebbAN8j0KQ63acdnIIUKSPc+jRY=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "commafeed-frontend";

    sourceRoot = "${src.name}/commafeed-client";

    npmDepsHash = "sha256-RrYqDANCprAj16B3skBs+T6sfmT4PqaAfuQ8xX4csVQ=";

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
  mvnHash = "sha256-ajrAjEzl5RBZC/ge3fmQoqzOP+W1S3XnfWf9cs6ZuDM=";

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

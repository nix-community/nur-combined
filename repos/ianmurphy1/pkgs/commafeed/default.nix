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
  binaryVersion = "7.3.2";
  version = "d4ce2a213fbf18ea37b7421c14bc5fbf12ea65ed";
  # version = binaryVersion;
  db = "h2";

  src = fetchFromGitHub {
    owner = "Athou";
    repo = "commafeed";
    rev = version;
    hash = "sha256-NHiw/rplfmByBqd2qKMMs1zJfWK9Sw4KqaoydJNzbtI=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "commafeed-frontend";

    sourceRoot = "${src.name}/commafeed-client";

    npmDepsHash = "sha256-6jdwRHZjsSmveRFIgpOqoaXMs+tZNWpsuHWKTH/HD5w=";

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
  mvnHash = "sha256-MHOCtBPl+l8ZGmtqcl7aUq+rp+E4N0Zf1RH8CmzNXBQ=";

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

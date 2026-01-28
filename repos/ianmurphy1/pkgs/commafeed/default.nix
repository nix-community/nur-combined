{
  lib,
  biome,
  buildNpmPackage,
  fetchFromGitHub,
  maven,
  nixosTests,
  writeText,
  graalvmPackages,
  removeReferencesTo,
  makeWrapper,
  glibc,
}:
let
  binaryVersion = "6.1.1";
  version = binaryVersion;
  db = "h2";

  graalVM = graalvmPackages.graalvm-ce;

  src = fetchFromGitHub {
    owner = "Athou";
    repo = "commafeed";
    rev = version;
    hash = "sha256-NdKCqK0XU3SjWwLc0eTeoi3jjC0d2MW8k2z7ulBM9WU=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "commafeed-frontend";

    sourceRoot = "${src.name}/commafeed-client";

    npmDepsHash = "sha256-XLHasjubyExhcOxRArxIR/VuOqfoSra0iu3s8hXnLyA=";

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

  mvnJdk = graalVM;
  mvnHash = "sha256-cgUYye9ZFuiwnu9J1Bnqw6UmQrIZRtzVF247Xr0RN3U=";

  mvnParameters = lib.escapeShellArgs [
    "-Pnative"
    "-P${db}"
    "-DskipTests"
    "-Dskip.installnodenpm"
    "-Dskip.npm"
    "-Dspotless.check.skip"
    "-Dmaven.gitcommitid.skip"
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
    graalVM
    maven
  ];

  postInstall = ''
    find "$out" -type f -exec ${lib.getExe removeReferencesTo} -t ${maven} -t ${graalVM} '{}' +
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

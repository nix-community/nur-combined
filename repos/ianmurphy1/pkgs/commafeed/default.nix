{
  lib,
  biome,
  buildNpmPackage,
  fetchFromGitHub,
  maven,
  nixosTests,
  writeText,
  graalvmCEPackages,
  removeReferencesTo,
}:
let
  version = "5.6.1";
  db = "h2";

  src = fetchFromGitHub {
    owner = "Athou";
    repo = "commafeed";
    rev = version;
    hash = "sha256-maN6egDJptulfB0mixE4C2H06HYpiTMW2O/HO3/mZh0=";
  };

  frontend = buildNpmPackage {
    inherit version src;
    pname = "commafeed-frontend";

    sourceRoot = "${src.name}/commafeed-client";

    npmDepsHash = "sha256-mVTj/buHYRfLLPHqmdPoksIONS3JbEeYgjv6XMoLmrk=";

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

  mvnJdk = graalvmCEPackages.graalvm-ce;
  mvnHash = "sha256-+9nyg2zrXkrDJuqVxUx2QRXiUDl8/Jna0FKhHpuJwqU=";

  mvnParameters = lib.escapeShellArgs [
    "-Pnative"
    "-P${db}"
    "-DskipTests"
    "-Dskip.installnodenpm"
    "-Dskip.npm"
    "-Dspotless.check.skip"
    "-Dmaven.gitcommitid.skip"
  ];

  nativeBuildInputs = [ graalvmCEPackages.graalvm-ce removeReferencesTo ];

  configurePhase = ''
    runHook preConfigure

    ln -sf "${frontend}" commafeed-client/dist

    cp ${gitProperties} commafeed-server/src/main/resources/git.properties

    runHook postConfigure
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share

    cp commafeed-server/target/quarkus-generated-doc/application.properties \
      $out/share/application.properties

    install -Dm755 commafeed-server/target/commafeed-${version}-${db}-linux-x86_64-runner \
      $out/bin/commafeed
      
    runHook postInstall
  '';

  postInstall = ''
    remove-references-to -t ${graalvmCEPackages.graalvm-ce} $out/bin/commafeed
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

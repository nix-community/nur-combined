{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  lib,
  gradle_9,
  jdk25,
  mainProgram ? "aya",
}:

let
  gradle = gradle_9;
  jdk = jdk25;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "aya-prover";
  version = "0.39";

  src = fetchFromGitHub {
    owner = finalAttrs.pname;
    repo = "aya-dev";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nl1ctsz1uRig+3L+Zbjle6eNZSiWOPxDCQshJh0zMW4=";
    leaveDotGit = true;
    # Only keep HEAD, because leaveDotGit is non-deterministic:
    # https://github.com/NixOS/nixpkgs/issues/8567
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  patches = [
    ./0001-fix-patch-on-gradle-deps-resolution.patch
    ./0002-fix-patch-GenerateVersionTask.patch
  ];

  postPatch = ''
    substituteInPlace buildSrc/src/main/groovy/org/aya/gradle/GenerateVersionTask.groovy \
      --replace-fail "\"__COMMIT_HASH__\"" "\"$(cat $src/COMMIT)\""
  '';

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  # this is required for using mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk}"
    "--debug"
    "--stacktrace"
  ];

  # defaults to "assemble"
  gradleBuildTask = "fatJar";

  # will run the gradleCheckTask (defaults to "test")
  # FIXME: fix gradle check
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/{aya,aya-lsp}}
    cp cli-console/build/libs/cli-console-${finalAttrs.version}.0-fat.jar $out/share/aya/cli-fatjar.jar
    cp ide-lsp/build/libs/ide-lsp-${finalAttrs.version}.0-fat.jar $out/share/aya-lsp/lsp-fatjar.jar

    makeWrapper ${lib.getExe jdk} $out/bin/aya \
      --add-flags "--enable-preview -jar $out/share/aya/cli-fatjar.jar"
    makeWrapper ${lib.getExe jdk} $out/bin/aya-lsp \
      --add-flags "--enable-preview -jar $out/share/aya-lsp/lsp-fatjar.jar"

    runHook postInstall
  '';

  meta = {
    homepage = "https://www.aya-prover.org";
    description = "A proof assistant and a dependently-typed language";
    licence = lib.licenses.mit;
    inherit mainProgram;
    maintainers = with lib.maintainers; [ definfo ];
    # See `supportedPlatforms` in build.gradle.kts
    platforms = [
      "aarch64-windows"
      "x86_64-windows"
      "aarch64-linux"
      "x86_64-linux"
      "riscv64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
  };
})

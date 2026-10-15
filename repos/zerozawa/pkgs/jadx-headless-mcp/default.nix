{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_9,
  jdk17_headless,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jadx-headless-mcp";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "1013503897";
    repo = "jadx-headless-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mCi6lt4HGqDSTtdcGEP0AoOYU9KHfdbSg7yXJn4a378=";
  };

  nativeBuildInputs = [
    gradle_9
    jdk17_headless
    makeBinaryWrapper
  ];

  # Upstream's Gradle wrapper pins 9.8.0, which is what nixpkgs' gradle_9 ships.
  mitmCache = gradle_9.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  # build.gradle.kts declares `kotlin { jvmToolchain(17) }`, and the offline build
  # (the Gradle setup hook passes --offline) cannot provision one from the network.
  gradleFlags = [
    "-Dorg.gradle.java.installations.paths=${jdk17_headless.home}"
    "-Dorg.gradle.java.installations.auto-download=false"
  ];

  # The `application` plugin's installDist output carries upstream's
  # applicationDefaultJvmArgs (-Xms128M, MaxRAMPercentage, slf4j->stderr).
  gradleBuildTask = "installDist";

  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jadx-headless-mcp
    cp -r build/install/jadx-headless-mcp/. $out/share/jadx-headless-mcp/

    mkdir -p $out/bin
    makeBinaryWrapper $out/share/jadx-headless-mcp/bin/jadx-headless-mcp \
      $out/bin/jadx-headless-mcp \
      --set JAVA_HOME ${jdk17_headless.home}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Headless MCP server for Android APK static analysis, built directly on jadx-core. No JADX GUI required, no Python adapter, no plugin to install — just one JVM process speaking MCP over stdio.";
    homepage = "https://github.com/1013503897/jadx-headless-mcp";
    license = licenses.asl20;
    mainProgram = "jadx-headless-mcp";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];
    platforms = platforms.unix;
  };
})

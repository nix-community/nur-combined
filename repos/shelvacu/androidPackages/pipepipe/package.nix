{
  fetchFromGitHub,
  runCommandLocal,
  buildGradleAndroidPackage,
  gradle_9,
  jdk25,
}:
let
  version = "5.2.5";

  # The InfinityLoop1308/PipePipe superproject is just a shell of git
  # submodules. The actual Android app lives in the PipePipeClient submodule,
  # which is a composite gradle build that includeBuild()s the
  # PipePipeExtractor submodule as a sibling directory. The submodule URLs use
  # ssh (git@github.com), so instead of fetchSubmodules we fetch each repo at
  # its pinned commit and reassemble the expected layout:
  #
  #   <src>/PipePipeClient      <- gradle build root
  #   <src>/PipePipeExtractor   <- includeBuild('../PipePipeExtractor')
  client = fetchFromGitHub {
    owner = "InfinityLoop1308";
    repo = "PipePipeClient";
    rev = "45939efccf87b23bad82b771821001a8f0755242";
    hash = "sha256-fkDlQ3xKGbKyjvKu3Z3XZDub28/tLoy9n6eFFUShOpo=";
  };
  extractor = fetchFromGitHub {
    owner = "InfinityLoop1308";
    repo = "PipePipeExtractor";
    rev = "aa72c9762706a919c4048ab56c921d09505d3e78";
    hash = "sha256-MEMv/6OHVL03xVL+HhTSDsv7R/UKGfdVete+dj+/RBI=";
  };
in
buildGradleAndroidPackage rec {
  pname = "pipepipe";
  inherit version;
  applicationId = "InfinityLoop1309.NewPipeEnhanced";

  src = runCommandLocal "pipepipe-source-${version}" { } ''
    mkdir -p $out
    cp -r ${client} $out/PipePipeClient
    cp -r ${extractor} $out/PipePipeExtractor
    chmod -R u+w $out
  '';
  sourceRoot = "pipepipe-source-${version}/PipePipeClient";

  # AGP 9.2.1 / Kotlin 2.3.21 target Java 25 and require a recent Gradle.
  gradle = gradle_9;
  jdk = jdk25;

  sdkVersions = [ "37" ];

  # compileSdk is 37, but AGP 9.2.1 defaults to build-tools 36.0.0.
  extraComposeArgs = {
    buildToolsVersions = [
      "36.0.0"
      "37.0.0"
    ];
  };

  gradleBuildTask = ":app:assembleRelease";

  lockFile = ./gradle.lock;
}

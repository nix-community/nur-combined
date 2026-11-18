{
  fetchFromGitHub,
  runCommandLocal,
  buildGradleAndroidPackage,
  gradle_9,
  jdk25,
}:
let
  version = "5.6.0-beta4";

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
    rev = "83e5fd896e891e9a4f1ca36301499284bcbd964d";
    hash = "sha256-FBZ0Szm+feEYyRzQD4HTsfEWvegzt9om/IjI3uTf4cc=";
  };
  extractor = fetchFromGitHub {
    owner = "InfinityLoop1308";
    repo = "PipePipeExtractor";
    rev = "5ebe2d928fbd2c6ca459e699381570da21403388";
    hash = "sha256-MdaT6SPHe6dcc9N2KVVGzrs+VqozgXU0CJSobfsa5Fg=";
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
  # unpackPhase only makes sourceRoot writable; the included extractor build writes to its own dir
  postUnpack = "chmod -R u+w pipepipe-source-${version}";

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

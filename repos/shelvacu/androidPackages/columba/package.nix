{
  fetchFromGitHub,
  buildGradleAndroidPackage,
  callPackage,
  gradle_9,
  jdk21_headless,
  python311,
}:
let
  wheels = callPackage ./wheels.nix { };
in
buildGradleAndroidPackage rec {
  pname = "columba";
  version = "2.2.6";
  applicationId = "network.columba.app";

  src = fetchFromGitHub {
    owner = "torlando-tech";
    repo = "columba";
    tag = "v${version}";
    hash = "sha256-F2hrtue4TwmHm2vDVVApa6l6GcoONJQVbD2T3axJt+g=";
  };

  postPatch = ''
    substituteInPlace rns-backend-py/build.gradle.kts \
      --replace-fail 'pip {' 'pip { options("--no-index", "--find-links", "${wheels}")' \
      --replace-fail 'install("git+https://github.com/torlando-tech/Reticulum@' 'install("rns") //' \
      --replace-fail 'install("git+https://github.com/torlando-tech/LXMF@' 'install("lxmf") //' \
      --replace-fail 'install("git+https://github.com/torlando-tech/ble-reticulum.git@' 'install("ble-reticulum") //'
  '';

  nativeBuildInputs = [ python311 ];

  sdkVersions = [ "36" ];

  gradle = gradle_9;
  jdk = jdk21_headless;

  lockFile = ./gradle.lock;

  gradleBuildTask = ":app:assembleNoSentryPythonBackendRelease";
  gradleDependenciesTask = gradleBuildTask;

  gradleBuildFlags = [
    "-PcolumbaVersionName=${version}"
    "-PcolumbaVersionCode=20206000"
  ];

  passthru = { inherit wheels; };
}

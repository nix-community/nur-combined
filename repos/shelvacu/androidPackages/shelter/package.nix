{ buildGradleAndroidPackage, fetchFromGitea }:
buildGradleAndroidPackage rec {
  pname = "shelter";
  version = "1.9.1";
  versionCode = 109010;

  applicationId = "net.typeblog.shelter";

  src = fetchFromGitea {
    domain = "gitea.angry.im";
    owner = "PeterCxy";
    repo = "Shelter";
    tag = version;
    fetchSubmodules = true;
    hash = "sha256-vFCml5ysW5Bgj01J5KsOru06l2sE40EHcUPOcnYSd64=";
  };

  patches = [ ./version.patch ];

  postPatch = ''
    substituteInPlace app/build.gradle \
      --replace-fail @versionCode@ ${toString versionCode} \
      --replace-fail @versionName@ ${version}
  '';

  sdkVersions = [
    "26"
    "33"
    "34"
  ];

  extraComposeArgs = {
    buildToolsVersions = [
      "33.0.1"
      "34.0.0"
    ];
  };

  lockFile = ./gradle.lock;

  meta.broken = true;
}

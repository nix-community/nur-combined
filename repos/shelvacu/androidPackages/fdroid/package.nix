{
  lib,
  fetchFromGitLab,
  buildGradleAndroidPackage,
}:
buildGradleAndroidPackage rec {
  pname = "fdroid";
  version = "1.23.2";
  applicationIds = [
    "org.fdroid.fdroid"
    "org.fdroid.basic"
  ];

  src = fetchFromGitLab {
    owner = "fdroid";
    repo = "fdroidclient";
    tag = version;
    hash = "sha256-qw+c2vPAkD+3bC9NIJLnIrKrXwhRJABkwoFZuz8vyeI=";
  };

  patches = [
    ./fix-other-sensors.patch
    ./version-from-nix.patch
    ./add-vacu-repo.patch
  ];

  postPatch = ''
    substituteInPlace app/build.gradle \
      --replace-fail '@versionFromNix@' "${version}-vacu" \
      --replace-fail 'versionCode ${toString passthru.originalVersionCode}' 'versionCode ${toString passthru.versionCode}'
  '';

  lockFile = ./gradle.lock;

  sdkVersions = [
    "34"
    "35"
  ];

  passthru = {
    originalVersionCode =
      let
        alpha = false;
        split = map lib.toInt (lib.splitVersion version);
        major = builtins.elemAt split 0;
        minor = builtins.elemAt split 1;
        patch = builtins.elemAt split 2;
        release = if alpha then 0 else 50;
      in
      patch + release + (minor * 1000) + (major * 1000000);
    vacuIncrement = 10;
    versionCode = passthru.originalVersionCode + passthru.vacuIncrement;
  };
}

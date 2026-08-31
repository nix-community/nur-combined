{
  fetchFromGitHub,
  lib,
  buildGoModule,
  unstableGitUpdater,
}:
buildGoModule (finalAttrs: {
  pname = "drone-file-secret";
  version = "0-unstable-2023-06-25";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "drone-file-secret";
    rev = "b69ba503becb41c72a1b724f38a26e7f2c34b110";
    hash = "sha256-aLr286rV6Ch3T1/r8Ru5JmRH1zDU6cfizGYzPW01snU=";
  };
  vendorHash = "sha256-5F831dsOw7BlqSJFLknp4lhsTPqv2suzWO+o3xX7Mnk=";

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/xddxdd/drone-file-secret";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Secret provider for Drone CI that reads secrets from a given folder";
    homepage = "https://github.com/xddxdd/drone-file-secret";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "drone-file-secret";
  };
})

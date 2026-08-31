{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sidestore-vpn";
  version = "0-unstable-2026-05-21";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "sidestore-vpn";
    rev = "1cb5f5d94e6f0baf4ed432d30b926bb0c39a9904";
    hash = "sha256-EKnLnTZjQHtBySO9uqvVJsX/7ps9uX3/PCrc2zLsakU=";
  };
  cargoHash = "sha256-DU5UT8N7n+qkPX7Gf4ue8E7bZZbfBp8dIKTWHMmAqMk=";

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/xddxdd/sidestore-vpn";
    hardcodeZeroVersion = true;
  };
  meta = {
    changelog = "https://github.com/xddxdd/sidestore-vpn/releases/tag/v${finalAttrs.version}";
    mainProgram = "sidestore-vpn";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Allow SideStore to work across all iOS devices on your local network";
    homepage = "https://github.com/xddxdd/sidestore-vpn";
    license = lib.licenses.unlicense;
  };
})

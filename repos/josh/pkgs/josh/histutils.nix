{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "histutils";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "histutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R4Qy04o3xXj1wq1DUx2eZH3dGFKhI2vqNk2X9JmxyHI=";
  };

  cargoHash = "sha256-QMDbJw08MyhJTS6fbUg7JiGrmq1XdNsSagh2ld3sRoM=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Import, export or merge zsh or fish history files";
    homepage = "https://github.com/josh/histutils";
    license = lib.licenses.mit;
    mainProgram = "histutils";
    platforms = lib.platforms.all;
  };
})

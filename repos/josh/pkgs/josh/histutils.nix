{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "histutils";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "histutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uA7BJmrvB2mOmURoOqzTNJbFIKcwdQoa5btGX8RiTJI=";
  };

  cargoHash = "sha256-AhQPL6+v9PyS9eGBWl52/EYAFrKSrX2Xbqqf7ODx2To=";

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

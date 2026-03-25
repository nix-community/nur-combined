{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "xurl";
  version = "0.0.27-unstable-2026-03-23";

  src = fetchFromGitHub {
    owner = "Xuanwo";
    repo = "xurl";
    rev = "24eedb2ff2b141b025efa1a1658fd7f3e88cdd01";
    hash = "sha256-M5GurO0O5LRDvFg6MtDZz40Qjdj3EKvzMiJWhVvwDwg=";
  };

  cargoHash = "sha256-us5+xKHjxO3d4tCnqSrvdoqi6v7ii+DdmIURykTcaH0=";

  nativeCheckInputs = [ git ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Client for AI Agents URLs";
    homepage = "https://github.com/Xuanwo/xurl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "xurl";
  };
}

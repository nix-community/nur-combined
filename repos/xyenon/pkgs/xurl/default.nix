{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "xurl";
  version = "0.0.24-unstable-2026-03-22";

  src = fetchFromGitHub {
    owner = "Xuanwo";
    repo = "xurl";
    rev = "ba1f6e355d21d3fdad59bd8bb7b75a2f0b0f3b5d";
    hash = "sha256-l+LMcCXYDqu85VNpRV+E3iCNgeMS3VZ/fSRD01AqzJ8=";
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

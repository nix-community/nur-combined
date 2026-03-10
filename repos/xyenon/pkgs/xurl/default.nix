{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "xurl";
  version = "0.0.22-unstable-2026-03-09";

  src = fetchFromGitHub {
    owner = "Xuanwo";
    repo = "xurl";
    rev = "fa30f4b436add23f0a0edf6abca166637c91f627";
    hash = "sha256-nIYKmTiexZCyRcC/JsKo0QNjrLbyh+GisJSOZPxQWa4=";
  };

  cargoHash = "sha256-AAoiruBie/Pa3tRJUweN35Ve7Q2l1T0qRQsWmi4XZ6g=";

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

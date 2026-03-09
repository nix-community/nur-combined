{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "xurl";
  version = "0-unstable-2026-03-04";

  src = fetchFromGitHub {
    owner = "Xuanwo";
    repo = "xurl";
    rev = "98943811af9c2aa1f7c930130a6788c64afb58a9";
    hash = "sha256-47DcbF4ay25OLh1aqQl6eEr2ZiyMtzExN7Z+Q7mNEoE=";
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

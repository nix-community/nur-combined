{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-19";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "23d6a2f6368486c8a9fca42fceee18d60db32151";
    hash = "sha256-SVANOuHtNOfmd/aC2NBs9mMYkWfc7t+U9sPbpSzfqhI=";
  };
  cargoRoot = "rust/uni-api-native";
  buildAndTestSubdir = "rust/uni-api-native";

  cargoHash = "sha256-Bi2EnrDP7MkFvsML5yVKzIrSmD26MY/ot0BJ2UrMD68=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Unifies the management of LLM APIs across multiple backend services";
    homepage = "https://github.com/yym68686/uni-api";
    license = lib.licenses.unfree;
    mainProgram = "uni-api-front";
  };
})

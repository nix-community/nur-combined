{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-20";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "d512d09905d63487ea80eb47a9b5d966e442bd9c";
    hash = "sha256-Hh5ns8pc9l1JtHQ+gjM4t8xSD/cuu2+Yy4+XogESclg=";
  };
  cargoRoot = "rust/uni-api-native";
  buildAndTestSubdir = "rust/uni-api-native";

  cargoHash = "sha256-o3CjXaMN/GJvxKA+i7mHVq6deGtqTBI5KEU9gKYCbdk=";

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

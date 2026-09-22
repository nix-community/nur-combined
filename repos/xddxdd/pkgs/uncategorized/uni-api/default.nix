{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-22";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "cd3a83dcc42d5e9521de678271f0f87a104a46a9";
    hash = "sha256-m7cQQRH2rXQl+iH0bMWlHRyVVjcfZ8rvGaZjEzjGJaY=";
  };
  cargoRoot = "rust/uni-api-native";
  buildAndTestSubdir = "rust/uni-api-native";

  cargoHash = "sha256-wvD2rHWTWlP50qpxUJviwYfKaExgao5Js4HCi1veuw8=";

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

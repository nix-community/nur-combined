{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-30";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "7f7e2c9559d25b76d2ebdd8e35bc6c24a95fc7ee";
    hash = "sha256-d+MbxYYG8wlLf+95KS85mTjW5/x3O5n5xFra+OuPYXA=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-SB6Yi0voeViUHI0BjSWVsHZfnTPHFkYrTyT8rJ7vcU0=";

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

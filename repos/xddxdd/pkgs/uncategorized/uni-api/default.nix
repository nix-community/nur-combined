{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-31";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "2e29d0c6ef6f6c96e24916b875c9c0c8fe558898";
    hash = "sha256-UeVnyUtSqsDEcMa/5UKv8mLJJ7z1rhhlCEVhOfdSYW8=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-F++LuJ8dcoIwa7o71cDkjygrR2qbfuXN6bvKXRme0gE=";

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

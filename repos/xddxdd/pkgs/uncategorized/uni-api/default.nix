{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-24";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "fa02a8b4452b6e50832d0638189202264a612e18";
    hash = "sha256-E/AVGbNrzHV3ZH8X0GC7DODA0et7cn9H+Toz2ZFKXYs=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-8bmb+1iewkk6UGnhldK8uBB2lRtVsIvUUiGoDCorqEw=";

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

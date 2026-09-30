{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-29";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "aca36ead19ad2781ffd2a03601f1e742b613ff3a";
    hash = "sha256-jbfdHdfnOJejwvHPBJhN1QYU6u8oFgof/C7zRfRpdUQ=";
  };
  cargoHash = "sha256-QQ0c4mwXcb/PflIm/XmaMKMppWVnMeQ+OXqDzTjcfZs=";

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

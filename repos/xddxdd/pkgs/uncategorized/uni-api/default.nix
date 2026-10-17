{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-17";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "85aeb746e240602213c15182ac6a36a1105b7d9a";
    hash = "sha256-ntQ6ch08CVI5qD/8TCvBmw2MyTp7FgTj80tnSNSfslQ=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-6k7rhe0AxUoPYJZiiwL12IAidP0GXzIL0fIRec2MqFY=";

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

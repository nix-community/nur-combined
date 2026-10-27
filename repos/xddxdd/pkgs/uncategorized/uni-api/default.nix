{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-26";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "0eaab0dd98c66036ade8d46526fd82ae29994498";
    hash = "sha256-6/rn/ni6pMH2RMOVsvJ0UQuKBK2ohsEyH3pZj60zwr4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-OvTGZDVhgaZEzu+G1wxj5Ol+FttBhmWQxZcIFRtyRG4=";

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

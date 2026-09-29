{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-28";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "9e66234bdabaa7f656c29adc1c1251b782d270c3";
    hash = "sha256-cuTeSEHLXGUrKzlKJwds4xvwHrXjY2zCr8VbnMg/unY=";
  };
  cargoHash = "sha256-MH2khBUz7Jj93gcVq85pfOPPCRcMijaDVv9ceiZuHnk=";

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

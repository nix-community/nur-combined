{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-30";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "7a287d9a5bc36e71cd0218aab8aee97b36f7e8a7";
    hash = "sha256-Gtk0g94HrqodK6Wy3dMVT1WM4lTygbQzrzsl9NJ32sI=";
  };
  cargoHash = "sha256-EiE4wroWEHdWbgnsUMavQ50PI3nQ8mdhatIOLt9eb2M=";

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

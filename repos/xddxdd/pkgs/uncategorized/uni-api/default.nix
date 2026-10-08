{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-07";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "b736dc9242a40272cd5f29d78d1337dbd44e8bbf";
    hash = "sha256-ODM86GrpmSM9e+fDFPbDDOciyz/kffeweIWwJQRIqLI=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-3wG4+lW7scWxagvS75zK32VZ9RGT7ImY0gTkXyxkV+k=";

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

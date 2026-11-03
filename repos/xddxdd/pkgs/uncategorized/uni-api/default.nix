{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-02";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "a25806695361071ecb53c7bf24117c4134c6f267";
    hash = "sha256-zL7kghVcSlgY+OsGtnqQWuelYpbaOCPm2rspJwWLMdw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-QEs5aFRvXRO2uKfSrSgMAAIQa8tN/oODaPREWXopk5c=";

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

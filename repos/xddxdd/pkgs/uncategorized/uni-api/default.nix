{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-09";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "daccc1633e4b126e7839c529db572231b50ce85a";
    hash = "sha256-5knYnRyC2ioEsNeSpifrnI/ss9VcnzVL99PtUr8kkfg=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-v5PKsnamz2dn6zAzoHIv4cT612P6RsZKBMCUnmD8coo=";

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

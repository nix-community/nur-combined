{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-14";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "b5373b9e8dafb67a5eb90ffbb128319e6606067b";
    hash = "sha256-jSgBCRe9XE1+EcQfE95fSwyi1LzfoU+Tz8Mm4v3Dvm4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-LnU+o+LoPR1HOhRfNNbIOMoy6FpppuTMTiPzbCxFQ7U=";

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

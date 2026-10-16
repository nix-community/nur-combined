{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-16";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "f60c0575069006d906bd5c8d499526ff84dbcf79";
    hash = "sha256-CepX5oQiGlZ57DY2IaODPoJbtMPWJE4ir9RsWsYDzXw=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-K9GbUQxObK8V11XQk7EF8HlCYaCV1KchunSEE3BYX8E=";

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

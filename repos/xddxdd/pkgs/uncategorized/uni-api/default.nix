{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-11-08";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "5311781b51b4ee85b3ebb9778bf46bde05d94e15";
    hash = "sha256-2SktlWcEDjMgECexcHBNdVc+boRwKeIKrkCKSyDxrow=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-vlPa61pPE0d0KhzVIt9+y/UJJxtyEtJkDDKVt4bOcH8=";

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

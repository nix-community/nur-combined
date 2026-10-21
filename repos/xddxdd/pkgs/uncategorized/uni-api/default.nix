{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-21";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "92c581801603642102fdf3dfbabf3550ed89c8c1";
    hash = "sha256-kTDnQO4fBuJsMqj4BD9MrzHx4f5M0j8qoau+A7hR4sA=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-Vap2j4DCoINNpA9SmQ2PeuI91vhh+6YgJ8CuEPN4UkU=";

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

{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-03";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "920e8d3d98cbf76fc3e4da5f5fb51aae0955101e";
    hash = "sha256-/OY6t74fvg0by+R8cr2BeBZ3itmXDsW5veV5VOaMMeE=";
  };
  cargoHash = "sha256-vxbfCg62jydfJ3qUio1hX1sohwp0SVzx+OmsdOIb6Uo=";

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

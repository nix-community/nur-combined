{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-09-26";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "b3daaaeb1686ab68585a22deb65f8adbef0f06ae";
    hash = "sha256-JrNk6UgNzOB25lzJUc4cpWwwEuvhcIL4NuVxH0wBP60=";
  };
  cargoHash = "sha256-1D50SAv6O0SHX4toddEh63A3tdbEs/AODmO823P3MnQ=";

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

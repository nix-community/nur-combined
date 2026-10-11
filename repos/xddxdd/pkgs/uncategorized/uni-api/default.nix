{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uni-api";
  version = "1.7.276-unstable-2026-10-11";
  src = fetchFromGitHub {
    owner = "yym68686";
    repo = "uni-api";
    rev = "07210ec1fac23b91e0ed7c305570247a52187949";
    hash = "sha256-Fk2HoXOG/ivqQrz7Rw0JNGX235BJjoxQfkc7eHzX23g=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  cargoHash = "sha256-jjHiq6rc2Wj97RfTdhimp5mVo/b5OQ34r2N52TCMbjM=";

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

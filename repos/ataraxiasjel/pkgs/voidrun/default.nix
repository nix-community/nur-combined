{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "voidrun";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = "voidrun-rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nvdR0QgcpyIcF3PaLXwhGAUIwOAMGbboBP1ukpTMyuo=";
  };

  cargoHash = "sha256-L16NEvMGGgFOf/3wUUPzM+uwMgizX6B+ENIzYX0mv8w=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A simple, isolated launcher for Linux games";
    homepage = "https://github.com/AtaraxiaSjel/voidrun-rs";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "voidrun";
    maintainers = with lib.maintainers; [ ataraxiasjel ];
    platforms = lib.platforms.linux;
  };
})

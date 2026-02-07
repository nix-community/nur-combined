{
  sources,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.sidestore-vpn) pname version src;

  cargoHash = "sha256-DU5UT8N7n+qkPX7Gf4ue8E7bZZbfBp8dIKTWHMmAqMk=";

  meta = {
    changelog = "https://github.com/xddxdd/sidestore-vpn/releases/tag/v${finalAttrs.version}";
    mainProgram = "sidestore-vpn";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Allow SideStore to work across all iOS devices on your local network";
    homepage = "https://github.com/xddxdd/sidestore-vpn";
    license = lib.licenses.unlicense;
  };
})
